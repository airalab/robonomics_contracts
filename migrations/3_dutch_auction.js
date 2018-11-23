const DutchAuction = artifacts.require("DutchAuction");

module.exports = async (deployer, network, accounts) => {

    const auction = require('../config')['auction'] 
    const wallet = accounts[0];

    await deployer.deploy(DutchAuction, accounts[0], auction['ceilingWei'], auction['priceFactor']);

};
