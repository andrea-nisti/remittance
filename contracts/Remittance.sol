pragma solidity ^0.4.23;
import "./Stoppable.sol";

contract Remittance is Stoppable {

    struct DepositStruct {
        uint amount;
        uint deadline;
        address sender;
    }
    
    mapping (bytes32 => DepositStruct) public deposits;
    mapping (bytes32 => bool) public usedPuzzles;

    bool running;
    
    constructor () public  {}

    //Events
    event LogNewDeposit(bytes32 puzzle, uint amount, address who);
    event LogNewWithdraw(address withdrawAddr, uint amount);
           
    //Create a new deposit
    function deposit(bytes32 puzzle, uint deadline) public payable isRunning {

        //Requires
        require (msg.value > 0);
        require (!usedPuzzles[puzzle]);
        
        //Create new deposit
        emit LogNewDeposit(puzzle, msg.value, msg.sender);
        usedPuzzles[puzzle] = true;
        
        deposits[puzzle] = DepositStruct({
            amount:       msg.value,
            deadline:     deadline + now,
            sender:       msg.sender
        });
    }

    //withdraw your eth, fuction used by the exchanger
    function giveMeMoney (string pass1, string pass2) public isRunning returns(bool res){
        
        bytes32 hashish   = giveMyHash(pass1,pass2, msg.sender);
        require (!isExpired(hashish), "Your deposit is expired");
        uint tAmount = deposits[hashish].amount;
        
        require (tAmount > 0, "Error fetching the deposit");
    
        //Transfer amount
        delete deposits[hashish];
        emit LogNewWithdraw(msg.sender, tAmount);
        msg.sender.transfer(tAmount);
        
        return true;        
    }

    //Returns the puzzle
    function giveMyHash (string pass1, string pass2, address exchangeAddr) public view returns(bytes32 hash) {

        return keccak256(abi.encodePacked(pass1, pass2, address(this), exchangeAddr));
        
    }

    //We compare with block time, not really precise but it's ok for now
    function isExpired(bytes32 puzzle) public view returns(bool res){
        return block.timestamp >= deposits[puzzle].deadline;
    }

    //When the deadline is over, give the amount back to the sender
    function giveMeMoneyBack (bytes32 puzzle) public isRunning returns(bool res){
        
        require (deposits[puzzle].amount > 0);
        require (isExpired(puzzle));        
        uint tAmount   = deposits[puzzle].amount;
        address sender = deposits[puzzle].sender;
        require (deposits[puzzle].sender == sender);
        
        delete deposits[puzzle];
        emit LogNewWithdraw(sender, tAmount);
        msg.sender.transfer(tAmount);
        return true;        
    }

    //Stop switch
    function killMe() public isRunning {
        require(msg.sender == owner);
        selfdestruct(owner);
    }

   
}       