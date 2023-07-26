const { ethers, deployments } = require('hardhat');
const hardhat = require('hardhat');
const namehash = require('eth-ens-namehash').hash;
const web3 = require('web3');
const { ensCheck, kyc, waiter } = require('./helpers/helpers');
const config = require('../config');
const networkName = hardhat.network.name

const chai = require('chai');
chai.use(require('chai-as-promised'));
chai.use(require("bn-chai")(web3.utils.BN));
chai.should();

let contracts;

before(async function () {
    const accounts = await hre.ethers.getSigners();
    await deployments.fixture();
    contracts = {
        ENS: (await ethers.getContract('ENS', accounts[0].address)),
        XRT: (await ethers.getContract('XRT', accounts[0].address)),
        PublicAmbix: (await ethers.getContract('PublicAmbix', accounts[0].address)),
        DutchAuction: (await ethers.getContract('DutchAuction', accounts[0].address)),
        Factory: (await ethers.getContract('Factory', accounts[0].address)),
    };

    await contracts.ENS.setSubnodeOwner('0x0000000000000000000000000000000000000000000000000000000000000000', web3.utils.sha3('eth'), accounts[0].address);
    await contracts.ENS.setSubnodeOwner(namehash('eth'), web3.utils.sha3('robonomics'), accounts[0].address);

    const foundation = networkName.startsWith('mainnet')
        ? config['foundation']
        : accounts[0].address;

    contracts.XRT.network = networkName;
    await contracts.XRT.addMinter(contracts.Factory.address);
    await contracts.XRT.transfer(foundation, config['xrt']['genesis']['foundation']);
    await contracts.XRT.transfer(contracts.PublicAmbix.address, config['xrt']['genesis']['ambix']);
    await contracts.XRT.transfer(contracts.DutchAuction.address, config['xrt']['genesis']['auction']);
    await contracts.XRT.renounceMinter();

    await contracts.DutchAuction.setup(contracts.XRT.address, contracts.PublicAmbix.address);
});

describe('when deployed', () => {
    it('should be resolved via ENS', async () => {
        await ensCheck('auction', contracts.DutchAuction.address);
    });

    it('should have XRT on balance', async () => {
        const balance = new web3.utils.BN(config['xrt']['genesis']['auction']).toNumber();
        const xrt_balance = (await contracts.XRT.balanceOf(contracts.DutchAuction.address)).toNumber();
        chai.expect(xrt_balance).equal(balance);
    });

    it('should have reference to XRT and Ambix contracts', async () => {
        chai.expect((await contracts.DutchAuction.token())).equal(contracts.XRT.address);
        chai.expect((await contracts.DutchAuction.ambix())).equal(contracts.PublicAmbix.address);
    });

    it('should have a signer for KYC validation', async () => {
        const accounts = await hre.ethers.getSigners();
        chai.expect((await contracts.DutchAuction.isSigner(accounts[0].address))).equal(true);
    });

    it('should be able to start', async () => {
        let result = await waiter({ func: contracts.DutchAuction.stage, value: 1, retries: 20 });
        chai.expect(result).equal(1);
        await contracts.DutchAuction.startAuction();
        result = await waiter({ func: contracts.DutchAuction.stage, value: 2, retries: 20 });
        chai.expect(result).equal(2);
    });
});

describe('when started', () => {
    it('should fail with invalid KYC signature', async () => {
        const accounts = await hre.ethers.getSigners();
        const payment = web3.utils.toWei('1', 'ether');
        chai.expect(contracts.DutchAuction.bid('0xcafe', { value: payment, from: accounts[1].address })).to.be.rejectedWith(Error);
    });

    it('should accept bid with valid KYC', async () => {
        const accounts = await hre.ethers.getSigners();
        const payment = web3.utils.toWei('10', 'ether');
        const signature = kyc(accounts[0].address, contracts.DutchAuction.address, accounts[1].address);
        await contracts.DutchAuction.bid(signature, { value: payment });
        chai.expect(await contracts.DutchAuction.bids(accounts[1].address)).equal(payment);
    });

    it('should accept finalize bid', async () => {
        const accounts = await hre.ethers.getSigners();
        const payment = web3.utils.toWei('2', 'ether');
        const signature = kyc(accounts[0].address, contracts.DutchAuction.address, accounts[2].address);

        for (let i = 0; i < 15; i += 1)
            await contracts.DutchAuction.bid(signature, { value: payment });

        const balance = web3.utils.toWei('30', 'ether');
        chai.expect(await contracts.DutchAuction.bids(accounts[2].address)).equal(balance);
        chai.expect((await contracts.DutchAuction.stage())).equal(2);

        await contracts.DutchAuction.bid(signature, { value: 9912, from: accounts[2].address })
        chai.expect((await contracts.DutchAuction.stage())).equal(3);
    });
});

describe('when ended', () => {
    it('should update to trading stage', async () => {
        await contracts.DutchAuction.updateStage();
        const result = await waiter({ func: contracts.DutchAuction.stage, value: 4, retries: 20 });
        chai.expect(result).equal(4);
    });

    it('claim tokens', async () => {
        const accounts = await hre.ethers.getSigners();

        const scale = new web3.utils.BN('1000000000');
        const finalPrice = await contracts.DutchAuction.finalPrice();

        const bid1 = await contracts.DutchAuction.bids(accounts[1].address);
        await contracts.DutchAuction.claimTokens({ from: accounts[1].address });
        chai.expect(await contracts.XRT.balanceOf(accounts[1].address)).equal(bid1.mul(scale).div(finalPrice));

        const bid2 = await contracts.DutchAuction.bids(accounts[2].address);
        await contracts.DutchAuction.claimTokens({ from: accounts[2].address });
        chai.expect(await contracts.XRT.balanceOf(accounts[2].address)).equal(bid2.mul(scale).div(finalPrice));

        await contracts.DutchAuction.claimTokens({ from: accounts[3].address });
        chai.expect(await contracts.XRT.balanceOf(accounts[3].address)).equal(new web3.utils.BN('0'));
    });
});

