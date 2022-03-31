const FumigaSA = artifacts.require("FumigaSA");
const FumToken = artifacts.require("FumToken");

module.exports = function (deployer) {
  deployer.deploy(FumToken);
  deployer.deploy(FumigaSA);
};



