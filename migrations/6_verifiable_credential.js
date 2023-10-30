var VerifiableCredential = artifacts.require("./VerifiableCredential.sol");

module.exports = function(deployer) {
  deployer.deploy(VerifiableCredential);
};
