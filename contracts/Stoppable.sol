pragma solidity ^0.4.23;
import "./Owned.sol";

contract Stoppable is Owned {
    
    bool private running;

    event LogOnSwitchChange(address who, bool actualState);
    
    constructor (bool initialState) public  {
        running = initialState;
    }
    
    //Mods
    modifier isRunning() { 
        require (running); 
        _; 
    }
    modifier isNotRunning() { 
        require (!running); 
        _; 
    }

    //Soft switches, define two different functions for user-friendliness
    function startSwitch() public onlyOwner returns(bool res){
        require(!running);
        running = true;
        emit LogOnSwitchChange(owner, running);
        return true;
    }
    function stopSwitch() public onlyOwner returns(bool res){
        require(running);
        running = false;
        emit LogOnSwitchChange(owner, running);
        return true;
    }

}