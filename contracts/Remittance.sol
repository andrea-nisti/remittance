pragma solidity ^0.4.23;
import "./Owned.sol";

contract Remittance is Owned {

	struct DepositStruct {
		uint value;
	 	uint deadline;
	 	address sender;
	 	address exchangeAddr;
	}
	
	mapping (bytes32 => DepositStruct) public deposits;
	
	constructor () public  {}

	//Events
	event LogNewDeposit(bytes32 puzzle, uint amount);
	event LogNewWithdraw(address withdrawAddr, uint amount);
	
	//Create a new deposit
	function deposit(bytes32 puzzle, uint deadline, address exchangeAddr) public payable  only_owner{

		//Requires
		require (msg.value > 0);
		require (deposits[puzzle].value == 0, "Puzzle already set");
		//Create new deposit
		emit LogNewDeposit(puzzle, msg.value);
		deposits[puzzle] = DepositStruct(msg.value, now + deadline, msg.sender, exchangeAddr);
	}

	//withdraw your eth, fuction used by the exchanger
	function giveMeMoney (string pass1, string pass2) public returns(bool res){
		
		bytes32 hashish   = giveMyHash(pass1,pass2);
		uint tAmount      = deposits[hashish].value;
		address tExchange = deposits[hashish].exchangeAddr;
		
		require (tAmount > 0);
		require (msg.sender == tExchange);

		//Transfer amount
		deposits[hashish].value = 0;
		emit LogNewWithdraw(tExchange, tAmount);
		msg.sender.transfer(tAmount);
		
		return true;		
	}

	//Returns the puzzle
	function giveMyHash (string pass1, string pass2) public pure returns(bytes32 hash) {

		return keccak256(abi.encodePacked(pass1, pass2));
		
	}

	//We compare with block time, not really precise but it's ok for now
	function isExpired(bytes32 puzzle)public view returns(bool res){
	
		require (deposits[puzzle].value > 0);
		
		if (block.timestamp >= deposits[puzzle].deadline)
        	return true;

        return false;

	}

	//When the deadline is over, give the amount back to the sender
	function giveMeMoneyBack (bytes32 puzzle) public returns(bool res){
		
		require (isExpired(puzzle));		
		uint tAmount   = deposits[puzzle].value;
		address sender = deposits[puzzle].sender;
		require (deposits[puzzle].sender == msg.sender);
		
		deposits[puzzle].value = 0;

		emit LogNewWithdraw(sender, tAmount);
		msg.sender.transfer(tAmount);
		return true;		
	}


	//Stop switch
	function killMe() public {
    	require(msg.sender == owner);
    	selfdestruct(owner);
    }

}