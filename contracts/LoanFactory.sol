pragma solidity ^0.4.15;
import "./LoanContract.sol";

contract LoanFactory {

    address[] public loans;
    address[] public borrowers; //may not be needed
    mapping(address => address) public borrowerLoanIndex;

    event LoanCreated(address loanAddress, address borrowerAddress);
    
    function loanCount() public view returns(uint256 _loanCount) {
        return loans.length;
    }
  
    // Gets the loan contract address for the given borrower address
    function getLoanForBorrower (address _borrowerAddress) public view returns(address _loanAddress) {
        return (borrowerLoanIndex[_borrowerAddress]);
    }

    // Creates a new loan contract with the data specified and adds it to the centralized loan repo
    function create (
        uint _loanAmountInEthers,
        uint _repaymentDurationInDays,
        string _ipfsHash
    ) public returns(address _loanAddress) {
        address borrowerAddress = msg.sender;
        uint fundRaisingDurationInDays = 30; //default to 30 for now
        address newLoanContract = new LoanContract(
            borrowerAddress, 
            _loanAmountInEthers, 
            fundRaisingDurationInDays, 
            _repaymentDurationInDays,
            _ipfsHash
        );
        loans.push(newLoanContract);
        borrowers.push(borrowerAddress);
        borrowerLoanIndex[borrowerAddress] = newLoanContract;
        LoanCreated(newLoanContract, borrowerAddress);
        return newLoanContract;
    }
}
