const Factory = artifacts.require('Factory');
const XRT = artifacts.require('XRT');

const { ensCheck } = require('./helpers/helpers')

const chai = require('chai');
chai.use(require('chai-as-promised'))
chai.should();

contract('XRT', () => {

    describe('when deployed', () => {
        it('should be resolved via ENS', async () => {
            await ensCheck('xrt', XRT.address);
        });

        it('should have factory as a minter', async () => {
            const xrt = await XRT.deployed();
            (await xrt.isMinter(Factory.address)).should.equal(true);
        });
    });

});
