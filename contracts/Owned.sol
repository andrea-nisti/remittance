pragma solidity ^0.4.23;

contract Owned {
    address public owner;
    constructor () public{
        owner = msg.sender;
    }
    event OwnerChanged(address indexed old, address indexed current);
    
    modifier onlyOwner { 
        require(msg.sender == owner);
        _;
    }
    function setOwner(address _newOwner) onlyOwner public {
        emit OwnerChanged(owner, _newOwner); 
        owner = _newOwner; 
    }

}