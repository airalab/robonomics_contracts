const { ethers, deployments } = require('hardhat');
const hardhat = require('hardhat');
const namehash = require('eth-ens-namehash').hash;
const web3 = require('web3');
const { ensCheck, kyc, waiter } = require('./helpers/helpers');
const config = require('../config');
const fs = require('fs');
const networkName = hardhat.network.name
const privateKeys = hardhat.network.config.accounts;
const chai = require('chai');
chai.use(require('chai-as-promised'));
chai.use(require("bn-chai")(web3.utils.BN));
chai.should();

let contracts;
const retryCounter = 100;
let tx;
let report = [];

before(async function () {
    const accounts = await hardhat.ethers.getSigners();
    await deployments.fixture();
    contracts = {
        ENS: (await ethers.getContract('ENS', accounts[0].address)),
        XRT: (await ethers.getContract('XRT', accounts[0].address)),
        PublicAmbix: (await ethers.getContract('PublicAmbix', accounts[0].address)),
        DutchAuction: (await ethers.getContract('DutchAuction', accounts[0].address)),
        Factory: (await ethers.getContract('Factory', accounts[0].address)),
    };

    await contracts.ENS.setSubnodeOwner(namehash(0), web3.utils.sha3('eth'), accounts[0].address);
    let result = await waiter({ func: contracts.ENS.owner, args: [namehash('eth')], value: accounts[0].address, retries: retryCounter });
    chai.expect(result).equal(accounts[0].address);

    await contracts.ENS.setSubnodeOwner(namehash('eth'), web3.utils.sha3('robonomics'), accounts[0].address);
    result = await waiter({ func: contracts.ENS.owner, args: [namehash('robonomics.eth')], value: accounts[0].address, retries: retryCounter });
    chai.expect(result).equal(accounts[0].address);

    const foundation = networkName.startsWith('mainnet')
        ? config['foundation']
        : accounts[0].address;

    contracts.XRT.network = networkName;
    const maxTokenSold = config['xrt']['genesis']['auction'];
    await contracts.XRT.addMinter(contracts.Factory.address);
    await contracts.XRT.transfer(foundation, config['xrt']['genesis']['foundation']);
    await contracts.XRT.transfer(contracts.PublicAmbix.address, config['xrt']['genesis']['ambix']);
    await contracts.XRT.transfer(contracts.DutchAuction.address, maxTokenSold);
    await contracts.XRT.renounceMinter();

    result = await waiter({ func: contracts.XRT.balanceOf, args: [contracts.DutchAuction.address], value: maxTokenSold, retries: retryCounter });
    chai.expect(result).equal(config['xrt']['genesis']['auction']);
    await contracts.DutchAuction.setup(contracts.XRT.address, contracts.PublicAmbix.address);
});

after(async function () {
    try {
        fs.appendFileSync("reports/DutchAuction_report.json", JSON.stringify(report));
    } catch (err) {
        console.log(err);
    }
});

describe('DutchAuction when deployed', () => {
    it('should be resolved via ENS', async () => {
        await ensCheck('auction', contracts.DutchAuction.address);
    });

    it('should have XRT on balance', async () => {
        const balance = new web3.utils.BN(config['xrt']['genesis']['auction']).toNumber();
        const xrt_balance = (await contracts.XRT.balanceOf(contracts.DutchAuction.address)).toNumber();
        chai.expect(xrt_balance).equal(balance);
    });

    it('should have reference to XRT and Ambix contracts', async () => {
        let token = await waiter({ func: contracts.DutchAuction.token, value: contracts.XRT.address, retries: retryCounter });
        let ambix = await waiter({ func: contracts.DutchAuction.ambix, value: contracts.PublicAmbix.address, retries: retryCounter });
        chai.expect(token).equal(contracts.XRT.address);
        chai.expect(ambix).equal(contracts.PublicAmbix.address);
    });

    it('should have a signer for KYC validation', async () => {
        const accounts = await hardhat.ethers.getSigners();
        chai.expect((await contracts.DutchAuction.isSigner(accounts[0].address))).equal(true);
    });

    it('should be able to start', async () => {
        const gasPrice = await hardhat.ethers.provider.getGasPrice();
        let result = await waiter({ func: contracts.DutchAuction.stage, value: 1, retries: retryCounter });
        chai.expect(result).equal(1);
        tx = await contracts.DutchAuction.startAuction();
        const txStarted = await tx.wait(1);
        report.push({
            "name": "DutchAuction started",
            "usedGas": txStarted["gasUsed"].toString(),
            "gasPrice": gasPrice.toString(),
            "tx": txStarted["transactionHash"]
        });
        result = await waiter({ func: contracts.DutchAuction.stage, value: 2, retries: retryCounter });
        chai.expect(result).equal(2);
    });
});

describe('DutchAuction when started', () => {
    it('should fail with invalid KYC signature', async () => {
        const accounts = await hardhat.ethers.getSigners();
        const payment = web3.utils.toWei('1', 'ether');
        chai.expect(contracts.DutchAuction.bid('0xcafe', { value: payment, from: accounts[1].address })).to.be.rejectedWith(Error);
    });

    it('should accept bid with valid KYC', async () => {
        const gasPrice = await hardhat.ethers.provider.getGasPrice();
        const accounts = await hardhat.ethers.getSigners();
        const payment = web3.utils.toWei('1', 'ether');

        const signature = await kyc(privateKeys[0], contracts.DutchAuction.address, accounts[0].address);
        tx = await contracts.DutchAuction.bid(signature, { value: payment });
        const txBid = await tx.wait(1);
        report.push({
            "name": "DutchAuction bid",
            "usedGas": txBid["gasUsed"].toString(),
            "gasPrice": gasPrice.toString(),
            "tx": txBid["transactionHash"]
        });

        const result = await waiter({ func: contracts.DutchAuction.bids, args: [accounts[0].address], value: payment, retries: retryCounter });
        chai.expect(result).equal(payment);
    });

    it('should accept finalize bid', async () => {
        const accounts = await hardhat.ethers.getSigners();
        const payment = web3.utils.toWei('2', 'ether');

        const signature = await kyc(privateKeys[0], contracts.DutchAuction.address, accounts[0].address);
        for (let i = 0; i < 15; i += 1)
            await contracts.DutchAuction.bid(signature, { value: payment });

        const balance = web3.utils.toWei('31', 'ether');
        const result = await waiter({ func: contracts.DutchAuction.bids, args: [accounts[0].address], value: balance, retries: retryCounter });
        chai.expect(result).equal(balance);

        let resultStage = await waiter({ func: contracts.DutchAuction.stage, value: 2, retries: retryCounter });
        chai.expect(resultStage).equal(2);

        // Finalize bid ( when value == 9912 => amount = maxWei => finalize auction)
        await contracts.DutchAuction.bid(signature, { value: 9912 });

        resultStage = await waiter({ func: contracts.DutchAuction.stage, value: 3, retries: retryCounter });
        chai.expect(resultStage).equal(3);
    });
});

describe('DutchAuction when ended', () => {
    it('should update to trading stage', async () => {
        const gasPrice = await hardhat.ethers.provider.getGasPrice();
        tx = await contracts.DutchAuction.updateStage();
        const txStage = await tx.wait(1);
        report.push({
            "name": "DutchAuction update stage",
            "usedGas": txStage["gasUsed"].toString(),
            "gasPrice": gasPrice.toString(),
            "tx": txStage["transactionHash"]
        });
        const result = await waiter({ func: contracts.DutchAuction.stage, value: 4, retries: retryCounter });
        chai.expect(result).equal(4);
    });

    it('claim tokens', async () => {
        const gasPrice = await hardhat.ethers.provider.getGasPrice();
        const accounts = await hardhat.ethers.getSigners();

        const scale = new web3.utils.BN('1000000000');
        const finalPrice = await contracts.DutchAuction.finalPrice();

        const bid = await contracts.DutchAuction.bids(accounts[0].address);
        const initialBalance = await contracts.XRT.balanceOf(accounts[0].address);

        tx = await contracts.DutchAuction.claimTokens();
        const txToken = await tx.wait(1);
        report.push({
            "name": "DutchAuction claim tokens",
            "usedGas": txToken["gasUsed"].toString(),
            "gasPrice": gasPrice.toString(),
            "tx": txToken["transactionHash"]
        });
        const finalBalance = (bid * scale / finalPrice) + initialBalance.toNumber();

        let result = await waiter({ func: contracts.XRT.balanceOf, args: [accounts[0].address], value: finalBalance, retries: retryCounter });
        chai.expect(result).equal(finalBalance);
    });
});

