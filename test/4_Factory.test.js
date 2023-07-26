const { ensCheck } = require('./helpers/helpers')
const chai = require('chai');
chai.use(require('chai-as-promised'))
chai.should();

let contracts;

before(async function () {
    await deployments.fixture();
    contracts = {
        XRT: (await ethers.getContract('XRT')),
        ENS: (await ethers.getContract('ENS')),
        Factory: (await ethers.getContract('Factory')),
    };
});

describe('factory contract', () => {
    it('shoudl be resolved via ENS', async () => {
        await ensCheck('factory', contracts.ENS.address);
    });

    it('should have correct contract refs', async () => {
        chai.expect((await contracts.Factory.xrt())).equal(contracts.XRT.address);
        chai.expect((await contracts.Factory.ens())).equal(contracts.ENS.address);
    });
});
