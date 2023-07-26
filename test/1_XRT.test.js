const { ethers, deployments } = require('hardhat');
const { ensCheck } = require('./helpers/helpers')
const config = require('../config');
const chai = require('chai');
chai.use(require('chai-as-promised'))
chai.should();


let contracts;

before(async function () {
    await deployments.fixture();
    contracts = {
        XRT: (await ethers.getContract('XRT')),
        Factory: (await ethers.getContract('Factory'))
    };
});

describe('when deployed', function () {
    it('should be resolved via ENS', async () => {
        await ensCheck('xrt', '0x0000000');
    });

    it('should have factory as a minter', async () => {
        await contracts.XRT.addMinterFromAddress(contracts.Factory.address);
        chai.expect((await contracts.XRT.isMinter(contracts.Factory.address))).equal(true);
    });
});
