const DutchAuction = artifacts.require("DutchAuction");

module.exports = async (deployer, network, accounts) => {

    const config = require('../config');
    const auction = require('../config')['auction'] 
    const wallet = accounts[0];

    await deployer.deploy(DutchAuction, accounts[0], config['xrt']['genesis']['auction'], auction['ceilingWei'], auction['priceFactor']);

};
