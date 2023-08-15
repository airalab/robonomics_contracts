const { ethers, deployments } = require('hardhat');
const { ensCheck, waiter } = require('./helpers/helpers')
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

describe('XRT when deployed', function () {
    it('should be resolved via ENS', async () => {
        await ensCheck('xrt', '0x0000000');
    });

    it('should have factory as a minter', async () => {
        await contracts.XRT.addMinter(contracts.Factory.address);
        const result = await waiter({ func: contracts.XRT.isMinter, args: [contracts.Factory.address], value: true, retries: 50 });
        chai.expect(result).equal(true);
    });
});
