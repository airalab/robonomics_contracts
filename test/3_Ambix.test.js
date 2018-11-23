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
    });

    it('static recipe', async () => {
        const ambix = await PublicAmbix.new();
        const source = await XRT.new(100);
        const sink = await XRT.new(1000);

        await ambix.setSink([sink.address], [1]).should.be.fulfilled;
        await ambix.appendSource([source.address], [10]).should.be.fulfilled;

        await source.transfer(accounts[1], 100).should.be.fulfilled;
        await sink.transfer(ambix.address, 100).should.be.fulfilled;

        await source.approve(ambix.address, 100, {from: accounts[1]}).should.be.fulfilled;
        await ambix.run(0, {from: accounts[1]}).should.be.fulfilled;

        (await sink.balanceOf(accounts[1])).toNumber().should.equal(10);
    });

    it('dynamic recipe', async () => {
        const ambix = await PublicAmbix.new();
        const source = await XRT.new(100);
        const sink = await XRT.new(1000);

        await ambix.setSink([sink.address], [0]).should.be.fulfilled;
        await ambix.appendSource([source.address], [0]).should.be.fulfilled;

        await source.transfer(accounts[1], 100).should.be.fulfilled;
        await sink.transfer(ambix.address, 1000).should.be.fulfilled;

        await source.approve(ambix.address, 100, {from: accounts[1]}).should.be.fulfilled;
        await ambix.run(0, {from: accounts[1]}).should.be.fulfilled;

        (await sink.balanceOf(accounts[1])).toNumber().should.equal(1000);
    });

    it('static recipe with KYC', async () => {
        const ambix = await KycAmbix.new();
        const source = await XRT.new(100);
        const sink = await XRT.new(1000);

        await ambix.setSink([sink.address], [1]).should.be.fulfilled;
        await ambix.appendSource([source.address], [10]).should.be.fulfilled;

        await source.transfer(accounts[1], 100).should.be.fulfilled;
        await sink.transfer(ambix.address, 100).should.be.fulfilled;

        await source.approve(ambix.address, 100, {from: accounts[1]}).should.be.fulfilled;
        
        const signature = await kyc(web3, kyc_account, ambix.address, accounts[1]);
        await ambix.run(0, signature, {from: accounts[1]}).should.be.fulfilled;

        (await sink.balanceOf(accounts[1])).toNumber().should.equal(10);
    });

    it('dynamic recipe with KYC', async () => {
        const ambix = await KycAmbix.new();
        const source = await XRT.new(100);
        const sink = await XRT.new(1000);

        await ambix.setSink([sink.address], [0]).should.be.fulfilled;
        await ambix.appendSource([source.address], [0]).should.be.fulfilled;

        await source.transfer(accounts[1], 100).should.be.fulfilled;
        await sink.transfer(ambix.address, 1000).should.be.fulfilled;

        await source.approve(ambix.address, 100, {from: accounts[1]}).should.be.fulfilled;

        const signature = await kyc(web3, kyc_account, ambix.address, accounts[1]);
        await ambix.run(0, signature, {from: accounts[1]}).should.be.fulfilled;

        (await sink.balanceOf(accounts[1])).toNumber().should.equal(1000);
    });

});
