pragma solidity ^0.4.23;

contract Owned {
	address public owner = msg.sender;
	event OwnerChanged(address indexed old, address indexed current);
	modifier only_owner { require(msg.sender == owner); _;}
	function setOwner(address _newOwner) only_owner public {emit OwnerChanged(owner, _newOwner); owner = _newOwner; }
}