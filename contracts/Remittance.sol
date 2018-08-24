pragma solidity ^0.4.23;
import "./Owned.sol";

contract Remittance is Owned {

	struct DepositStruct {
		uint    value;
	 	uint time;
	 	address exchangeAddr;
	}
	
	mapping (bytes32 => DepositStruct) public deposits;
	
	constructor () public  {}

	//Events
	event LogNewDeposit(bytes32 puzzle, uint value);
	event LogNewWithdraw(address exchangeAddr, uint amount);
	
	function deposit(bytes32 puzzle, address exchangeAddr) public payable  only_owner{

		//Requires
		require (msg.value > 0);
		require (deposits[puzzle].value == 0, "Puzzle already set");
		//Create new deposit
		emit LogNewDeposit(puzzle, msg.value);
		deposits[puzzle] = DepositStruct(msg.value,now,exchangeAddr);
	}
	function giveMeMoney (string pass1, string pass2) public returns(bool res){
		
		uint tAmount      = deposits[hashish].value;
		address tExchange = deposits[hashish].exchangeAddr;
		bytes32 hashish   = giveMyHash(pass1,pass2);
		
		require (tAmount > 0);
		require (msg.sender == tExchange);

		//Transfer amount
		deposits[hashish].value = 0;
		emit LogNewWithdraw(tExchange, tAmount);
		msg.sender.transfer(tAmount);
		
		return true;		
	}
	function giveMyHash (string pass1, string pass2) public pure returns(bytes32 hash) {

		return keccak256(abi.encodePacked(pass1, pass2));
		
	}

	//Stop switch
	function killMe() public {
    	require(msg.sender == owner);
    	selfdestruct(owner);
    }

}