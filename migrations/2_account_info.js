var AccountInfo = artifacts.require("./AccountInfo.sol");

module.exports = function(deployer) {
  deployer.deploy(AccountInfo);
};
