const DutchAuction = artifacts.require('DutchAuction');
const KycAmbix = artifacts.require('KycAmbix');
const XRT = artifacts.require('XRT');

const { ensCheck, kyc } = require('./helpers/helpers')
const config = require('../config');

const chai = require('chai');
chai.use(require('chai-as-promised'))
chai.use(require("bn-chai")(web3.utils.BN));
chai.should();

contract('DutchAuction', (accounts) => {
    const kyc_account = accounts[0];

    describe('when deployed', () => {
        it('should be resolved via ENS', async () => {
            await ensCheck('auction', DutchAuction.address);
        });

        it('should have XRT on balance', async () => {
            const xrt = await XRT.deployed();
            const balance = new web3.utils.BN(config['xrt']['genesis']['auction']).toNumber(); 
            (await xrt.balanceOf(DutchAuction.address)).toNumber().should.equal(balance);
        });

        it('should have reference to XRT and Ambix contracts', async () => {
            const auction = await DutchAuction.deployed();
            (await auction.token()).should.equal(XRT.address);
            (await auction.ambix()).should.equal(KycAmbix.address);
        });

        it('should have a signer for KYC validation', async () => {
            const auction = await DutchAuction.deployed();
            (await auction.isSigner(kyc_account)).should.equal(true);
        });

        it('should be able to start', async () => {
            const auction = await DutchAuction.deployed();
            await auction.startAuction({from: accounts[0]}).should.be.fulfilled;
            (await auction.stage()).toNumber().should.equal(2);
        });
    });

    describe('when started', () => {
        it('should fail with invalid KYC signature', async () => {
            const auction = await DutchAuction.deployed();
            const payment = web3.utils.toWei('1', 'ether');
            await auction.bid('0xcafe', {value: payment, from: accounts[1]}).should.be.rejected;
        });

        it('should accept bid with valid KYC', async () => {
            const auction = await DutchAuction.deployed();
            const payment = web3.utils.toWei('10', 'ether');
            const signature = await kyc(web3, kyc_account, DutchAuction.address, accounts[1]);
            await auction.bid(signature, {value: payment, from: accounts[1]}).should.be.fulfilled;
            chai.expect(await auction.bids(accounts[1])).to.eq.BN(payment);
        });

        it('should accept finalize bid', async () => {
            const auction = await DutchAuction.deployed();
            const payment = web3.utils.toWei('2', 'ether');
            const signature = await kyc(web3, kyc_account, DutchAuction.address, accounts[2]);

            for (let i = 0; i < 15; i += 1)
                await auction.bid(signature, {value: payment, from: accounts[2]}).should.be.fulfilled;

            const balance = web3.utils.toWei('30', 'ether');
            chai.expect(await auction.bids(accounts[2])).to.eq.BN(balance);

            (await auction.stage()).toNumber().should.equal(3);
        });
    });

    describe('when ended', () => {
        it('should update to trading stage', async () => {
            const auction = await DutchAuction.deployed();
            await auction.updateStage().should.be.fulfilled;
            (await auction.stage()).toNumber().should.equal(4);
        });

        it('claim tokens', async () => {
            const auction = await DutchAuction.deployed();
            const xrt = await XRT.deployed();

            const scale = new web3.utils.BN('1000000000');
            const finalPrice = await auction.finalPrice();

            const bid1 = await auction.bids(accounts[1]);
            await auction.claimTokens({from: accounts[1]}).should.be.fulfilled;
            chai.expect(await xrt.balanceOf(accounts[1])).to.eq.BN(bid1.mul(scale).div(finalPrice));

            const bid2 = await auction.bids(accounts[2]);
            await auction.claimTokens({from: accounts[2]}).should.be.fulfilled;
            chai.expect(await xrt.balanceOf(accounts[2])).to.eq.BN(bid2.mul(scale).div(finalPrice));

            await auction.claimTokens({from: accounts[3]}).should.be.fulfilled;
            chai.expect(await xrt.balanceOf(accounts[3])).to.eq.BN(new web3.utils.BN('0'));
        });
    });

});
