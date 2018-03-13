pragma solidity ^0.4.15;
/*
    A simple loan contract which allows lenders to lend and borrowers to repay
*/
contract LoanContract {
    //Constructor vars
    address public borrowerAddress;
    uint public loanAmount;
    uint public repaymentDuration;
    uint public fundRaisingDeadline;
    uint public repaymentDeadline;
    string public ipfsHash;
    
    //Useful vars
    uint public amountRaised;
    uint public amountRepaid;
    /* Since solidity doesn't allow iterating over mapping, we need 2 data structures to represent lender accounts */
    address[] public lenderAddresses;
    mapping(address => LenderAccount) public lenderAccounts;
    enum State {raising, funded, repaying, repaid, expired}
    State public currentState;
    struct LenderAccount {
        uint amountLent;
        uint amountRepaid;
        uint amountWithdrawn;
    }
    PaymentEntry[] public schedule;
    PaymentEntry[] public payments;
    struct PaymentEntry {
        uint date;
        uint amount;
    }
    
    //Events
    event LentToLoan(address addr, uint amount);
    event DisbursedToBorrower(address addr, uint amount);
    event RepaidByBorrower(address addr, uint amount);
    event RepaidToLender(address addr, uint amount);
    event SentBack(address addr, uint amount);
    event LenderWithdrew(address addr, uint amount);
    event LoanFunded();
    event LoanExpired();
    event LoanRepaid();
    
    // Constructor
    function LoanContract(
        address _borrowerAddress, 
        uint _loanAmountInEthers,
        uint _fundRaisingDurationInDays,
        uint _repaymentDurationInDays,
        string _ipfsHash
    ) public {
        borrowerAddress = _borrowerAddress;
        loanAmount = _loanAmountInEthers * 1 ether;
        repaymentDuration = _repaymentDurationInDays;
        fundRaisingDeadline = now + _fundRaisingDurationInDays * 1 days;
        repaymentDeadline = fundRaisingDeadline + _repaymentDurationInDays * 1 days;
        ipfsHash = _ipfsHash;
        // For now just do a single scheduled payment at the end
        schedule.push(PaymentEntry(repaymentDeadline, loanAmount));
    }
    
    // Lender sends wei to the contract, we store how much they lent
    function lend() payable public {
        // Don't allow borrowers to lend, or allow overfunding
        require(msg.sender != borrowerAddress);
        require(msg.value <= amountLeftToFund());
        
        // Handle lender lending twice
        if (lenderAccounts[msg.sender].amountLent == 0) {
            lenderAddresses.push(msg.sender);
            lenderAccounts[msg.sender] = LenderAccount(msg.value, 0, 0);
        } else {
            lenderAccounts[msg.sender].amountLent += msg.value;
        }
        
        amountRaised += msg.value;
        LentToLoan(msg.sender, msg.value);
        
        checkLoanFunded();
    }
    
    // If we have raised the full loan amount, then transition to funded
    function checkLoanFunded() private {
        if (amountRaised >= loanAmount) {
            currentState = State.funded;
            LoanFunded();
        }
    }
    
    // The recommended pattern for disbursals is to have the borrower withdraw
    function borrowerWithdraw() public {
         // Only borrowers can withdraw, and only in the funded state
        require(msg.sender == borrowerAddress);
        require(currentState == State.funded);
        
        if (amountRaised > 0) {
            currentState = State.repaying;
            msg.sender.transfer(amountRaised);
            DisbursedToBorrower(borrowerAddress, amountRaised);
        }
    }
    
    // Borrower sends wei to the contract, we record the amount repaid
    function repay() payable public {
        // Only borrowers can repay, and can't repay more than the amount left
        require(msg.sender == borrowerAddress);
        require(currentState == State.repaying);
        require(msg.value <= amountLeftToRepay());
        
        amountRepaid += msg.value;
        RepaidByBorrower(borrowerAddress, msg.value);
        payments.push(PaymentEntry(now, msg.value));
        
        // Distribute wei evenly to lenders, if there's a remainder we'll distribute at the end
        uint amountToDistribute = msg.value;
        uint amountDistributed = 0;
        for (uint i = 0; i < lenderAddresses.length; i++) {
            address currentLender = lenderAddresses[i];
            uint amountForLender = getAmountForLender(amountToDistribute, lenderAccounts[currentLender]);
            if (amountForLender > 0) {
                RepaidToLender(currentLender, amountForLender);
                lenderAccounts[currentLender].amountRepaid += amountForLender;
                amountDistributed += amountForLender;
            }
        }
        
        checkLoanRepaid();
    }
    
    function getAmountForLender(uint amountToDistribute, LenderAccount account) private view returns (uint) {
        if (amountRepaid != loanAmount) {
            // Regular case, division in solidity throws away the remainder
            return (amountToDistribute * account.amountLent) / loanAmount;
        } else {
            // Last repayment case, make sure everyone is topped up
            return account.amountLent - account.amountRepaid;
        }
    }
    
    function checkLoanRepaid() private {
        if (amountRepaid == loanAmount) {
            currentState = State.repaid;
            LoanRepaid();
        }
    }
    
    // The recommended pattern for lender's to recieve repayments is to have them withdraw
    function lenderWithdraw() public {
        uint amountToWithdraw = amountLenderCanWithdraw(msg.sender);
        if (amountToWithdraw > 0) {
            lenderAccounts[msg.sender].amountWithdrawn += amountToWithdraw;
            msg.sender.transfer(amountToWithdraw);
            LenderWithdrew(msg.sender, amountToWithdraw);
        }
    }
    
    // Calculates how much the lender can withdraw based on loan state
    function amountLenderCanWithdraw(address lenderAddr) public view returns (uint) {
        uint amountCanWithdraw = 0;
        LenderAccount storage lenderAccount = lenderAccounts[lenderAddr];
        if (currentState == State.expired) {
            /* If the loan expired, lenders can withdraw their contributed amount*/
            amountCanWithdraw = lenderAccount.amountLent - lenderAccount.amountWithdrawn;
        } else if (currentState == State.repaying || currentState == State.repaid) {
            /* If the loan is repaying or fully repaid the lenders can withdraw however much has been repaid to them */
            amountCanWithdraw = lenderAccount.amountRepaid - lenderAccount.amountWithdrawn;
        }
        return amountCanWithdraw;
    }

    // Solidity doesn't support timer calls, so an admin will have to call this
    function makeExpired() public {
         if (now >= fundRaisingDeadline && amountRaised < loanAmount) {
            currentState = State.expired;
            LoanExpired();
        }
    }
    
    /* Useful constant functions */
    
    function numLenders() public view returns (uint) {
        return lenderAddresses.length;
    }
    
    function amountLeftToFund() public view returns (uint) {
        return loanAmount - amountRaised;
    }
    
    function amountLeftToRepay() public view returns (uint) {
        return loanAmount - amountRepaid;
    }
    
    function isDelinquent() public view returns (bool) {
        return (now >= repaymentDeadline && currentState != State.repaid);
    }
}
