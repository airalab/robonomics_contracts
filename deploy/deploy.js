const hardhat = require('hardhat');
const networkName = hardhat.network.name
// const [accounts] = hardhat.network.config.accounts
const config = require('../config');
const auction = config['auction'];

module.exports = async ({ deployments }) => {
    const { deploy } = deployments;
    const accounts = await hre.ethers.getSigners();

    await deploy('Migrations', {
        from: accounts[0].address,
        args: [],
        log: true,
    });

    const ens = await deploy('ENS', {
        from: accounts[0].address,
        args: [],
        log: true,
    });

    const xrt = await deploy('XRT', {
        from: accounts[0].address,
        args: [config['xrt']['initialSupply']],
        log: true,
    });

    const publicAmbix = await deploy('PublicAmbix', {
        from: accounts[0].address,
        args: [],
        log: true,
    });

    const liability = await deploy('Liability', {
        from: accounts[0].address,
        args: [],
        log: true,
    });

    const lighthouse = await deploy('Lighthouse', {
        from: accounts[0].address,
        args: [],
        log: true,
    });

    await deploy('KycAmbix', {
        from: accounts[0].address,
        args: [],
        log: true,
    });

    const dutchAuction = await deploy('DutchAuction', {
        from: accounts[0].address,
        args: [networkName.startsWith('mainnet') ? auction['wallet'] : accounts[0].address,
        config['xrt']['genesis']['auction'],
        auction['ceilingWei'],
        auction['priceFactor']],
        log: true,
        execute: {
            methodName: 'setup',
            args: [xrt.address, publicAmbix.address],
        },
    });

    const ens_address = networkName.startsWith('mainnet')
        ? '0x314159265dD8dbb310642f98f50C066173C1259b'
        : ens.address;

    await deploy('Factory', {
        from: accounts[0].address,
        args: [liability.address,
        lighthouse.address,
        dutchAuction.address,
            ens_address,
        xrt.address],
        log: true,
    });
};
module.exports.tags = ['Migrations', 'ENS', 'DutchAuction', 'Liability', 'Lighthouse', 'XRT', 'PublicAmbix', 'KycAmbix', 'Factory'];
  