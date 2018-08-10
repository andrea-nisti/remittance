pragma solidity ^0.4.23;
import "./UtilsLib.sol";

contract Owned {
	address public owner = msg.sender;
	event OwnerChanged(address indexed old, address indexed current);
	modifier only_owner { require(msg.sender == owner); _;}
	//function setOwner(address _newOwner) only_owner public { OwnerChanged(owner, _newOwner); owner = _newOwner; }
}

contract Remittance is Owned {

	struct depositStruct {
		uint    value;
	 	uint256 time;
	}
	
	mapping (bytes32 => depositStruct) public deposits;
	
	constructor () public  {}
	
	function deposit(bytes32 puzzle) public payable  only_owner{

		//Asserts
		require (msg.value > 0);
		
		//Create new deposit
		deposits[puzzle] = depositStruct(msg.value,now);

	}	
	
	function getCurrentBalance ()  public view returns(uint){
		return address(this).balance;
	}

	function giveMeMoney (string pass1, string pass2) public returns(bytes32 res){
		
		bytes32 hashish = UtilsLib.getKekka(pass1,pass2);
		require (deposits[hashish].value > 0);

		//Transfer amount
		msg.sender.transfer(deposits[hashish].value);
		deposits[hashish].value;
		return hashish;		
	}

}