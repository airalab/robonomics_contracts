const DutchAuction = artifacts.require("DutchAuction");

const wallet = "";
const ceiling = 3 * 10**18;
const priceFactor = 2;

module.exports = function(deployer, network, accounts) {

  if (network == "development") {
    deployer.deploy(DutchAuction, accounts[0], ceiling, priceFactor);
  } else {
    deployer.deploy(DutchAuction, wallet, ceiling, priceFactor);
  }

};
