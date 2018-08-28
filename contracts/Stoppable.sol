pragma solidity ^0.4.23;
import "./Owned.sol";

contract Stoppable is Owned {
	
	bool running;
    constructor () public  {
    	running = true;
    }
    event LogOnSwitchChange(address who, bool actualState);
    //Mods
    modifier isRunning() { 
        require (running); 
        _; 
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