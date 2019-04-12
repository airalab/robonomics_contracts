const DutchAuction = artifacts.require("DutchAuction");

module.exports = async (deployer, network, accounts) => {

    const config = require('../config');
    const auction = config['auction'];

    await deployer.deploy(DutchAuction,
        network.startsWith('mainnet') ? auction['wallet'] : accounts[0],
        config['xrt']['genesis']['auction'],
        auction['ceilingWei'],
        auction['priceFactor']
    );

};
