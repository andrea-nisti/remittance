pragma solidity ^0.4.23;
import "./UtilsLib.sol";

contract Owned {
	address public owner = msg.sender;
	event OwnerChanged(address indexed old, address indexed current);
	modifier only_owner { require(msg.sender == owner); _;}
	//function setOwner(address _newOwner) only_owner public { OwnerChanged(owner, _newOwner); owner = _newOwner; }
}

contract Remittance is Owned {

	struct DepositStruct {
		uint    value;
	 	uint256 time;
	 	address exchangeAddr;
	}
	
	mapping (bytes32 => DepositStruct) public deposits;
	
	constructor () public  {}
	
	function deposit(bytes32 puzzle, ) public payable  only_owner{

		//Requires
		require (msg.value > 0);
		require (deposits[puzzle].value == 0, "Puzzle already set");
		//Create new deposit
		deposits[puzzle] = DepositStruct(msg.value,now);
	}
	
	function giveMeMoney (string pass1, string pass2) public returns(bool res){
				
		bytes32 hashish = UtilsLib.getKekka(pass1,pass2);
		require (deposits[hashish].value > 0);
		require (msg.sender == deposits[hashish].exchangeAddr);

		//Transfer amount
		deposits[hashish].value = 0;
		msg.sender.transfer(deposits[hashish].value);
		
		return true;		
	}

	//Stop switch
	function killMe() public {
    	assert(msg.sender == owner);
    	selfdestruct(owner);
    }

}