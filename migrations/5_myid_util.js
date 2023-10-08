var MyIdUtil = artifacts.require("./MyIdUtil.sol");

module.exports = function(deployer) {
  deployer.deploy(MyIdUtil);
};
