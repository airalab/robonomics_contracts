const Factory = artifacts.require('Factory');
const ENS = artifacts.require('ENS');
const XRT = artifacts.require('XRT');

const { ensCheck, kyc } = require('./helpers/helpers')
const config = require('../config');

const chai = require('chai');
chai.use(require('chai-as-promised'))
chai.should();

contract('Factory', () => {

    it('shoudl be resolved via ENS', async () => {
        await ensCheck('factory', ENS.address);
    });

    it('should have correct contract refs', async () => {
        const factory = await Factory.deployed();
        chai.expect((await factory.xrt())).equal(XRT.address);
        chai.expect((await factory.ens())).equal(ENS.address);
    });

});
