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
    event LogOnSwitchChange(address who, bool actualState);
    
    //Mods
    modifier isRunning() { 
        require (running); 
        _; 
    }
    
    //Create a new deposit
    function deposit(bytes32 puzzle, uint deadline, address exchangeAddr) public payable isRunning {

        //Requires
        require (msg.value > 0);
        require (!usedPuzzles[puzzle]);
        
        //Create new deposit
        emit LogNewDeposit(puzzle, msg.value, msg.sender);
        usedPuzzles[puzzle] = true;
        
        deposits[puzzle] = DepositStruct({
            amount:       msg.value,
            deadline:     deadline,
            sender:       msg.sender,
            exchangeAddr: exchangeAddr
        });
    }

    //withdraw your eth, fuction used by the exchanger
    function giveMeMoney (string pass1, string pass2) public isRunning returns(bool res){
        
        bytes32 hashish   = giveMyHash(pass1,pass2);
        require (!isExpired(hashish));
        uint tAmount      = deposits[hashish].amount;
        address tExchange = deposits[hashish].exchangeAddr;
        
        require (tAmount > 0);
        require (msg.sender == tExchange);

        //Transfer amount
        delete deposits[puzzle];
        emit LogNewWithdraw(tExchange, tAmount);
        msg.sender.transfer(tAmount);
        
        return true;        
    }

    //Returns the puzzle
    function giveMyHash (string pass1, string pass2) public pure returns(bytes32 hash) {

        return keccak256(abi.encodePacked(pass1, pass2, address(this)));
        
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

    //Soft switches, define two different functions for user-friendliness
    function startSwitch() public only_owner returns(bool res){
        require(!running);
        running = true;
        emit LogOnSwitchChange(owner, running);
        return true;
    }
    function stopSwitch() public only_owner returns(bool res){
        require(running);
        running = false;
        emit LogOnSwitchChange(owner, running);
        return true;
    }
}       