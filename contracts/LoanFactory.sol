pragma solidity ^0.4.15;

contract LoanFactory {

  mapping(address => bytes32) public loans;

  event LoanCreated(address indexed _address, bytes32 _name);

  function exists (address _address) public constant returns (bool _exists) {
    return (loans[_address] != bytes32(0));
  }

  function create (bytes32 _name) public {
    loans[msg.sender] = _name ;
    LoanCreated(msg.sender, _name);
  }

  function get (address _address) public constant returns(bytes32 _name) {
    require(exists(_address));
    return (loans[_address]);
  }

}
