const hardhat = require("hardhat");
const { ensCheck, waiter, smartWaiter } = require('./helpers/helpers')
const chai = require('chai');
const web3 = require('web3');
const fs = require('fs');
chai.use(require('chai-as-promised'))
chai.use(require("bn-chai")(web3.utils.BN));
chai.should();

let contracts;
let ambix;
let source;
let sink;
let tx;
const retryCounter = 100;
let report = [];

before(async function () {
    await deployments.fixture();
    contracts = {
        ENS: (await ethers.getContract('ENS')),
        PublicAmbix: (await ethers.getContract('PublicAmbix')),
    };
});

after(async function () {
    if (!fs.existsSync("reports")){
        fs.mkdirSync("reports");
    }
    try {
        fs.appendFileSync("reports/Ambix_report.json", JSON.stringify(report));
    } catch (err) {
        console.log(err);
    }
});

beforeEach(async function () {
    const token = await ethers.getContractFactory('XRT');
    source = await token.deploy(100);
    sink = await token.deploy(1000);

    const tokenAmbix = await ethers.getContractFactory('PublicAmbix');
    ambix = await tokenAmbix.deploy();
});

describe('Ambix', () => {
    it('should be resolved via ENS', async () => {
        await ensCheck('ambix', contracts.PublicAmbix.address);
    });

    it('static recipe', async () => {
        const gasPrice = await hardhat.ethers.provider.getGasPrice();
        const accounts = await hardhat.ethers.getSigners();

        let resultInitial = await waiter({ func: sink.balanceOf, args: [accounts[0].address], value: 1000, retries: retryCounter });
        chai.expect(resultInitial).equal(1000);

        tx = await contracts.PublicAmbix.setSink([sink.address], [1]);
        const txSetSink = await tx.wait(1);
        report.push({
            "name": "PublicAmbix setSink",
            "usedGas": txSetSink["gasUsed"].toString(),
            "gasPrice": gasPrice.toString(),
            "tx": txSetSink["transactionHash"]
        });
        const token = await smartWaiter({ func: contracts.PublicAmbix.getOutputToken, check: (r) => r != undefined, retries: retryCounter });
        chai.expect(token).not.equal(undefined);

        tx = await contracts.PublicAmbix.appendSource([source.address], [10]);
        const txAppend = await tx.wait(1);
        report.push({
            "name": "PublicAmbix appendSource",
            "usedGas": txAppend["gasUsed"].toString(),
            "gasPrice": gasPrice.toString(),
            "tx": txAppend["transactionHash"]
        });
        await source.transfer(accounts[0].address, 100);
        await sink.transfer(contracts.PublicAmbix.address, 100);

        const resultIntermediate = await waiter({ func: sink.balanceOf, args: [accounts[0].address], value: 900, retries: retryCounter });
        chai.expect(resultIntermediate).equal(resultInitial - 100);

        const sourceResult = await waiter({ func: source.balanceOf, args: [accounts[0].address], value: 100, retries: retryCounter });
        chai.expect(sourceResult).equal(100);

        const sinkResult = await waiter({ func: sink.balanceOf, args: [contracts.PublicAmbix.address], value: 100, retries: retryCounter });
        chai.expect(sinkResult).equal(100);

        tx = await source.approve(contracts.PublicAmbix.address, 100);
        const txApprove = await tx.wait(1);
        report.push({
            "name": "XRT approve",
            "usedGas": txApprove["gasUsed"].toString(),
            "gasPrice": gasPrice.toString(),
            "tx": txApprove["transactionHash"]
        });
        const allowance = await waiter({ func: source.allowance, args: [accounts[0].address, contracts.PublicAmbix.address], value: 100, retries: retryCounter });
        chai.expect(allowance).equal(100);

        tx = await contracts.PublicAmbix.run(0);
        const txRun = await tx.wait(1);
        report.push({
            "name": "PublicAmbix run",
            "usedGas": txRun["gasUsed"].toString(),
            "gasPrice": gasPrice.toString(),
            "tx": txRun["transactionHash"]
        });
        const result = await waiter({ func: sink.balanceOf, args: [accounts[0].address], value: 910, retries: retryCounter });
        chai.expect(result - resultIntermediate).equal(10);
    });

    it('dynamic recipe', async () => {
        const gasPrice = await hardhat.ethers.provider.getGasPrice();
        const accounts = await hardhat.ethers.getSigners();

        const resultInitial = await waiter({ func: sink.balanceOf, args: [accounts[0].address], value: 1000, retries: retryCounter });
        chai.expect(resultInitial).equal(1000);

        tx = await ambix.setSink([sink.address], [0]);
        const txSetSink = await tx.wait(1);
        report.push({
            "name": "KycAmbix setSink",
            "usedGas": txSetSink["gasUsed"].toString(),
            "gasPrice": gasPrice.toString(),
            "tx": txSetSink["transactionHash"]
        });
        const token = await smartWaiter({ func: ambix.getOutputToken, check: (r) => r != undefined, retries: retryCounter });
        chai.expect(token).not.equal(undefined);

        tx = await ambix.appendSource([source.address], [0]);
        const txAppend = await tx.wait(1);
        report.push({
            "name": "KycAmbix appendSource",
            "usedGas": txAppend["gasUsed"].toString(),
            "gasPrice": gasPrice.toString(),
            "tx": txAppend["transactionHash"]
        });
        await source.transfer(accounts[0].address, 100);
        await sink.transfer(ambix.address, 1000);

        const sourceResult = await waiter({ func: source.balanceOf, args: [accounts[0].address], value: 100, retries: retryCounter });
        chai.expect(sourceResult).equal(100);

        const sinkResult = await waiter({ func: sink.balanceOf, args: [ambix.address], value: 1000, retries: retryCounter });
        chai.expect(sinkResult).equal(1000);

        await source.approve(ambix.address, 100);
        const allowance = await waiter({ func: source.allowance, args: [accounts[0].address, ambix.address], value: 100, retries: retryCounter });
        chai.expect(allowance).equal(100);
        tx = await ambix.run(0);
        const txRun = await tx.wait(1);
        report.push({
            "name": "KycAmbix run",
            "usedGas": txRun["gasUsed"].toString(),
            "gasPrice": gasPrice.toString(),
            "tx": txRun["transactionHash"]
        });

        const result = await waiter({ func: sink.balanceOf, args: [accounts[0].address], value: 1000, retries: retryCounter });
        chai.expect(result).equal(1000);
    });

});
