var DigitalSignature = artifacts.require("./DigitalSignature.sol");

module.exports = function(deployer) {
  deployer.deploy(DigitalSignature);
};
