pragma solidity ^0.4.23;
import "./Remittance";


contract RemittanceDerived is Remittance {

	function giveMyHash (string pass1, string pass2) public pure returns(byte32 hash) {

		return UtilsLib.getKekka(pass1,pass2);
		
	}
	
}