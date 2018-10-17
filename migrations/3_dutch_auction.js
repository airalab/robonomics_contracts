const DutchAuction = artifacts.require("DutchAuction");

const wallet = "";
const ceiling = 4 * 10**18;
const priceFactor = 600;

module.exports = function(deployer, network, accounts) {

  if (network == "development" || network === 'testing') {
    deployer.deploy(DutchAuction, accounts[0], ceiling, priceFactor);
  } else {
    deployer.deploy(DutchAuction, wallet, ceiling, priceFactor);
  }

};
