var DIDRegistry = artifacts.require("./DIDRegistry.sol");

module.exports = function(deployer) {
  deployer.deploy(DIDRegistry);
};
