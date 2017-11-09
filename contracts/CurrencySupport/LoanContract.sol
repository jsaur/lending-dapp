pragma solidity ^0.4.15;
import "./CurrencyConversionOracle.sol";

/*
    A simple loan contract which allows lenders to lend and borrowers to repay
    This version allows you to denominate the loan in a stable fiat currency
    and use ether as the medium of exchange. However there are currently some
    penny rounding bugs.
*/
contract LoanContract {
    //Constructor vars
    address public borrowerAddress;
    uint public repaymentDuration;
    uint public fundRaisingDeadline;
    uint public repaymentDeadline;
    bytes3 public currencyCode; // 3-letter currency code eg 'USD'
    uint public loanAmountInCurrencyCents;
    uint public loanAmountInWei;
    string public name;
    string public use;
    CurrencyConversionOracle public currencyConversionOracle;
    
    //Useful vars
    uint public amountRaisedInCurrencyCents;
    uint public amountRaisedInWei;
    uint public amountRepaidInCurrencyCents;
    uint public amountRepaidInWei;
    /* Since solidity doesn't allow iterating over mapping, we need 2 data structures to represent lender accounts */
    address[] public lenderAddresses;
    mapping(address => LenderAccount) public lenderAccounts;
    enum State {raising, funded, repaying, repaid, expired}
    State public currentState;
    struct LenderAccount {
        uint amountLentInWei;
        uint amountLentInCurrencyCents;
        uint amountRepaidInWei;
        uint amountRepaidInCurrencyCents;
        uint amountWithdrawnInWei;
    }
    PaymentEntry[] public schedule;
    PaymentEntry[] public payments;
    struct PaymentEntry {
        uint date;
        uint amountInWei;
        uint amountInCurrencyCents;
        bytes3 currencyCode;
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
        uint _loanAmountInCurrencyUnits,
        uint _fundRaisingDurationInDays,
        uint _repaymentDurationInDays,
        string _name,
        string _use,
        bytes3 _currencyCode,
        CurrencyConversionOracle _currencyConversionOracle
    ) public {
        borrowerAddress = _borrowerAddress;
        loanAmountInCurrencyCents = _loanAmountInCurrencyUnits * 100;
        repaymentDuration = _repaymentDurationInDays;
        fundRaisingDeadline = now + _fundRaisingDurationInDays * 1 days;
        repaymentDeadline = fundRaisingDeadline + _repaymentDurationInDays * 1 days;
        name = _name;
        use = _use;
       
        // Handle currency
        currencyCode = _currencyCode;
        currencyConversionOracle = _currencyConversionOracle;
        loanAmountInWei = _currencyConversionOracle.oneCurrencyUnitInWei(currencyCode) * _loanAmountInCurrencyUnits;
        
         // For now just do a single scheduled payment at the end
        schedule.push(PaymentEntry(repaymentDeadline, loanAmountInWei, loanAmountInCurrencyCents, currencyCode));
    }
    
    // Lender sends wei to the contract, we store how much they lent
    function lend() payable public {
        // Don't allow borrowers to lend, or allow overfunding
        require(msg.sender != borrowerAddress);
        require(msg.value <= amountLeftToFundInWei());
        
        uint lenderAmountInWei = msg.value;
        uint lenderAmountInCurrencyCents = currencyConversionOracle.oneEthInCurrencyCents(currencyCode) * msg.value / 1 ether;
        
        // Handle lender lending twice
        if (lenderAccounts[msg.sender].amountLentInWei == 0) {
            lenderAddresses.push(msg.sender);
            lenderAccounts[msg.sender] = LenderAccount(lenderAmountInWei, lenderAmountInCurrencyCents, 0, 0, 0);
        } else {
            lenderAccounts[msg.sender].amountLentInWei += lenderAmountInWei;
            lenderAccounts[msg.sender].amountLentInWei += lenderAmountInCurrencyCents;
        }
        
        amountRaisedInWei += lenderAmountInWei;
        amountRaisedInCurrencyCents += lenderAmountInCurrencyCents;
        LentToLoan(msg.sender, lenderAmountInWei);
        
        checkLoanFunded();
    }
    
    // If we have raised the full loan amount, then transition to funded
    function checkLoanFunded() private {
        if (amountRaisedInCurrencyCents >= loanAmountInCurrencyCents) {
            currentState = State.funded;
            LoanFunded();
        }
    }
    
    // The recommended pattern for disbursals is to have the borrower withdraw
    function borrowerWithdraw() public {
         // Only borrowers can withdraw, and only in the funded state
        require(msg.sender == borrowerAddress);
        require(currentState == State.funded);
        
        if (amountRaisedInWei > 0) {
            currentState = State.repaying;
            msg.sender.transfer(amountRaisedInWei);
            DisbursedToBorrower(borrowerAddress, amountRaisedInWei);
        }
    }
    
    // Borrower sends wei to the contract, we record the amount repaid
    function repay() payable public {
        // Only borrowers can repay, and can't repay more than the amount left
        require(msg.sender == borrowerAddress);
        require(currentState == State.repaying);
        
        uint borrowerAmountInWei = msg.value;
        uint borrowerAmountInCurrencyCents = currencyConversionOracle.oneEthInCurrencyCents(currencyCode) * msg.value / 1 ether;
        require(borrowerAmountInCurrencyCents <= amountLeftToRepayInCurrencyCents());
        
        amountRepaidInWei += borrowerAmountInWei;
        amountRepaidInCurrencyCents += borrowerAmountInCurrencyCents;
        RepaidByBorrower(borrowerAddress, amountRepaidInWei);
        payments.push(PaymentEntry(now, borrowerAmountInWei, borrowerAmountInCurrencyCents, currencyCode));
        
        // Distribute wei evenly to lenders, if there's a remainder we'll distribute at the end
        uint amountToDistributeInWei = amountRepaidInWei;
        uint amountDistributedInWei = 0;
        for (uint i = 0; i < lenderAddresses.length; i++) {
            address currentLender = lenderAddresses[i];
            uint amountForLenderInWei = getAmountForLender(amountToDistributeInWei, lenderAccounts[currentLender]);
            if (amountForLenderInWei > 0) {
                RepaidToLender(currentLender, amountForLenderInWei);
                lenderAccounts[currentLender].amountRepaidInWei += amountForLenderInWei;
                lenderAccounts[currentLender].amountRepaidInCurrencyCents += currencyConversionOracle.oneEthInCurrencyCents(currencyCode) * amountForLenderInWei / 1 ether;
                amountDistributedInWei += amountForLenderInWei;
            }
        }
        
        checkLoanRepaid();
    }
    
    function getAmountForLender(uint amountToDistribute, LenderAccount account) private view returns (uint) {
        if (amountRepaidInWei != loanAmountInWei) {
            // Regular case, division in solidity throws away the remainder
            return (amountToDistribute * account.amountLentInWei) / loanAmountInWei;
        } else {
            // Last repayment case, make sure everyone is topped up
            return account.amountLentInWei - account.amountRepaidInWei;
        }
    }
    
    function checkLoanRepaid() private {
        if (amountRepaidInCurrencyCents == loanAmountInCurrencyCents) {
            currentState = State.repaid;
            LoanRepaid();
        }
    }
    
    // The recommended pattern for lender's to recieve repayments is to have them withdraw
    function lenderWithdraw() public {
        uint amountToWithdraw = amountLenderCanWithdraw(msg.sender);
        if (amountToWithdraw > 0) {
            lenderAccounts[msg.sender].amountWithdrawnInWei += amountToWithdraw;
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
            amountCanWithdraw = lenderAccount.amountLentInWei - lenderAccount.amountWithdrawnInWei;
        } else if (currentState == State.repaying || currentState == State.repaid) {
            /* If the loan is repaying or fully repaid the lenders can withdraw however much has been repaid to them */
            amountCanWithdraw = lenderAccount.amountRepaidInWei - lenderAccount.amountWithdrawnInWei;
        }
        return amountCanWithdraw;
    }

    // Solidity doesn't support timer calls, so an admin will have to call this
    function makeExpired() public {
         if (now >= fundRaisingDeadline && amountRaisedInCurrencyCents < loanAmountInCurrencyCents) {
            currentState = State.expired;
            LoanExpired();
        }
    }
    
    /* Useful constant functions */
    
    function numLenders() public view returns (uint) {
        return lenderAddresses.length;
    }
    
    function amountLeftToFundInCurrencyCents() public view returns (uint) {
        return loanAmountInCurrencyCents - amountRaisedInCurrencyCents;
    }
    
    function amountLeftToFundInWei() public view returns (uint) {
        return loanAmountInWei - amountRaisedInWei;
    }
    
    function amountLeftToRepayInCurrencyCents() public view returns (uint) {
        return loanAmountInCurrencyCents - amountRepaidInCurrencyCents;
    }
    
    function amountLeftToRepayInWei() public view returns (uint) {
        return loanAmountInWei - amountRepaidInWei;
    }
    
    function isDelinquent() public view returns (bool) {
        return (now >= repaymentDeadline && currentState != State.repaid);
    }
}