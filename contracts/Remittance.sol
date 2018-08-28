pragma solidity ^0.4.23;
import "./Owned.sol";

contract Remittance is Owned {

    struct DepositStruct {
        uint amount;
        uint deadline;
        address sender;
        address exchangeAddr;
    }
    
    mapping (bytes32 => DepositStruct) public deposits;
    mapping (bytes32 => bool) private usedPuzzles;

    bool running;
    
    constructor () public  {
        running = true;
    }

    //Events
    event LogNewDeposit(bytes32 puzzle, uint amount, address who);
    event LogNewWithdraw(address withdrawAddr, uint amount);

    //Mods
    modifier isRunning() { 
        require (running); 
        _; 
    }
    
    //Create a new deposit
    function deposit(bytes32 puzzle, uint deadline, address exchangeAddr) public payable isRunning  only_owner{

        //Requires
        uint value = msg.value;
        require (value > 0);
        require (!usedPuzzles[puzzle]);
        require (deposits[puzzle].amount == 0, "Puzzle already set");
        
        //Create new deposit
        address sender = msg.sender;
        emit LogNewDeposit(puzzle, value, sender);
        usedPuzzles[puzzle] = true;
        
        deposits[puzzle] = DepositStruct({
            amount:       value,
            deadline:     deadline,
            sender:       sender,
            exchangeAddr: exchangeAddr
        });
    }

    //withdraw your eth, fuction used by the exchanger
    function giveMeMoney (string pass1, string pass2) public isRunning returns(bool res){
        
        bytes32 hashish   = giveMyHash(pass1,pass2);
        uint tAmount      = deposits[hashish].amount;
        address tExchange = deposits[hashish].exchangeAddr;
        
        require (tAmount > 0);
        require (msg.sender == tExchange);

        //Transfer amount
        deposits[hashish].amount = 0;
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
        return block.timestamp >= deposits[puzzle].deadline;
    }

    //When the deadline is over, give the amount back to the sender
    function giveMeMoneyBack (bytes32 puzzle) public isRunning returns(bool res){
        
        require (deposits[puzzle].amount > 0);
        require (isExpired(puzzle));        
        uint tAmount   = deposits[puzzle].amount;
        address sender = deposits[puzzle].sender;
        require (deposits[puzzle].sender == sender);
        
        deposits[puzzle].amount = 0;

        emit LogNewWithdraw(sender, tAmount);
        msg.sender.transfer(tAmount);
        return true;        
    }

    //Stop switch
    function killMe() public isRunning {
        require(msg.sender == owner);
        selfdestruct(owner);
    }

    //Soft switches, define two different functions for user-friendliness
    function startSwitch() public returns(bool res){
        require(msg.sender == owner);
        require(!running);
        running = true;
        return true;
    }
    function stopSwitch() public returns(bool res){
        require(msg.sender == owner);
        require(running);
        running = false;
        return true;
    }
}       