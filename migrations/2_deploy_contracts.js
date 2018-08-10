var UtilsLib = artifacts.require("./UtilsLib.sol");
var Remittance = artifacts.require("./Remittance.sol");

module.exports = function(deployer) {
  deployer.deploy(UtilsLib);
  deployer.link(UtilsLib,Remittance);
  deployer.deploy(Remittance);
};
