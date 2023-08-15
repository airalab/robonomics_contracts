const hardhat = require("hardhat");
const { ensCheck, waiter, smartWaiter } = require('./helpers/helpers')
const chai = require('chai');
const web3 = require('web3');
chai.use(require('chai-as-promised'))
chai.use(require("bn-chai")(web3.utils.BN));
chai.should();

let contracts;
let ambix;
let source;
let sink;
const retryCounter = 100;

before(async function () {
    await deployments.fixture();
    contracts = {
        ENS: (await ethers.getContract('ENS')),
        PublicAmbix: (await ethers.getContract('PublicAmbix')),
    };
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
        const accounts = await hardhat.ethers.getSigners();

        let resultInitial = await waiter({ func: sink.balanceOf, args: [accounts[0].address], value: 1000, retries: retryCounter });
        chai.expect(resultInitial).equal(1000);

        await contracts.PublicAmbix.setSink([sink.address], [1]);
        const token = await smartWaiter({ func: contracts.PublicAmbix.getOutputToken, check: (r) => r != undefined, retries: retryCounter });
        chai.expect(token).not.equal(undefined);

        await contracts.PublicAmbix.appendSource([source.address], [10]);
        await source.transfer(accounts[0].address, 100);
        await sink.transfer(contracts.PublicAmbix.address, 100);

        const resultIntermediate = await waiter({ func: sink.balanceOf, args: [accounts[0].address], value: 900, retries: retryCounter });
        chai.expect(resultIntermediate).equal(resultInitial - 100);

        const sourceResult = await waiter({ func: source.balanceOf, args: [accounts[0].address], value: 100, retries: retryCounter });
        chai.expect(sourceResult).equal(100);

        const sinkResult = await waiter({ func: sink.balanceOf, args: [contracts.PublicAmbix.address], value: 100, retries: retryCounter });
        chai.expect(sinkResult).equal(100);

        await source.approve(contracts.PublicAmbix.address, 100);
        const allowance = await waiter({ func: source.allowance, args: [accounts[0].address, contracts.PublicAmbix.address], value: 100, retries: retryCounter });
        chai.expect(allowance).equal(100);

        await contracts.PublicAmbix.run(0);

        const result = await waiter({ func: sink.balanceOf, args: [accounts[0].address], value: 910, retries: retryCounter });
        chai.expect(result - resultIntermediate).equal(10);
    });

    it('dynamic recipe', async () => {
        const accounts = await hardhat.ethers.getSigners();

        const resultInitial = await waiter({ func: sink.balanceOf, args: [accounts[0].address], value: 1000, retries: retryCounter });
        chai.expect(resultInitial).equal(1000);

        await ambix.setSink([sink.address], [0]);
        const token = await smartWaiter({ func: ambix.getOutputToken, check: (r) => r != undefined, retries: retryCounter });
        chai.expect(token).not.equal(undefined);

        await ambix.appendSource([source.address], [0]);
        await source.transfer(accounts[0].address, 100);
        await sink.transfer(ambix.address, 1000);

        const sourceResult = await waiter({ func: source.balanceOf, args: [accounts[0].address], value: 100, retries: retryCounter });
        chai.expect(sourceResult).equal(100);

        const sinkResult = await waiter({ func: sink.balanceOf, args: [ambix.address], value: 1000, retries: retryCounter });
        chai.expect(sinkResult).equal(1000);

        await source.approve(ambix.address, 100);
        const allowance = await waiter({ func: source.allowance, args: [accounts[0].address, ambix.address], value: 100, retries: retryCounter });
        chai.expect(allowance).equal(100);
        await ambix.run(0);

        const result = await waiter({ func: sink.balanceOf, args: [accounts[0].address], value: 1000, retries: retryCounter });
        chai.expect(result).equal(1000);
    });

});
