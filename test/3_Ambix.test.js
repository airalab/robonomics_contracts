const PublicAmbix = artifacts.require('PublicAmbix');
const KycAmbix = artifacts.require('KycAmbix');
const ENS = artifacts.require('ENS');
const XRT = artifacts.require('XRT');

const { ensCheck, kyc } = require('./helpers/helpers')
const config = require('../config');

const chai = require('chai');
chai.use(require('chai-as-promised'))
chai.use(require("bn-chai")(web3.utils.BN));
chai.should();

contract('Ambix', (accounts) => {
    const kyc_account = accounts[0];

    it('should be resolved via ENS', async () => {
        await ensCheck('ambix', ENS.address);
        return;
    });

    it('static recipe', async () => {
        await PublicAmbix.deployed()
        const ambix = await PublicAmbix.new();
        await XRT.deployed()
        const source = await XRT.new(100);
        const sink = await XRT.new(1000);

        await ambix.setSink([sink.address], [3]);
        await ambix.appendSource([source.address], [10]);

        await source.transfer(accounts[1], 100);
        await sink.transfer(ambix.address, 100);

        await source.approve(ambix.address, 100, { from: accounts[1] });
        await ambix.run(0, { from: accounts[1] });

        chai.expect((await sink.balanceOf(accounts[1])).toNumber()).equal(30);

        await new Promise((resolve) => { resolve(); return; });
    });

    it('dynamic recipe', async () => {
        await PublicAmbix.deployed()
        await new Promise((resolve) => setTimeout(resolve, 10000))
        const ambix = await PublicAmbix.new();

        await XRT.deployed()
        const source = await XRT.new(100);
        const sink = await XRT.new(1000);

        await ambix.setSink([sink.address], [0]);
        await ambix.appendSource([source.address], [0]);

        await source.transfer(accounts[1], 100);
        await sink.transfer(ambix.address, 1000);

        await source.approve(ambix.address, 100, { from: accounts[1] });
        await ambix.run(0, { from: accounts[1] });

        chai.expect((await sink.balanceOf(accounts[1])).toNumber()).equal(1000);
    });

    it('static recipe with KYC', async () => {
        await KycAmbix.deployed();
        const ambix = await KycAmbix.new();
        await XRT.deployed()
        const source = await XRT.new(100);
        const sink = await XRT.new(1000);

        await ambix.setSink([sink.address], [1]);
        await ambix.appendSource([source.address], [10]);

        await source.transfer(accounts[1], 100);
        await sink.transfer(ambix.address, 100);

        await source.approve(ambix.address, 100, { from: accounts[1] });

        const signature = await kyc(web3, kyc_account, ambix.address, accounts[1]);
        await ambix.run(0, signature, { from: accounts[1] });

        chai.expect((await sink.balanceOf(accounts[1])).toNumber()).equal(10);
    });

    it('dynamic recipe with KYC', async () => {
        await KycAmbix.deployed();
        const ambix = await KycAmbix.new();
        await XRT.deployed()
        const source = await XRT.new(100);
        const sink = await XRT.new(1000);

        await ambix.setSink([sink.address], [0]);
        await ambix.appendSource([source.address], [0]);

        await source.transfer(accounts[1], 100);
        await sink.transfer(ambix.address, 1000);
        await source.approve(ambix.address, 100, { from: accounts[1] });

        const signature = await kyc(web3, kyc_account, ambix.address, accounts[1]);
        await ambix.run(0, signature, { from: accounts[1] });
        chai.expect((await sink.balanceOf(accounts[1])).toNumber()).equal(1000);
    });

});
