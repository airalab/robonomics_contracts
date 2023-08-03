const hre = require("hardhat");
const { ensCheck, kyc, waiter } = require('./helpers/helpers')
const chai = require('chai');
const web3 = require('web3');
chai.use(require('chai-as-promised'))
chai.use(require("bn-chai")(web3.utils.BN));
chai.should();

let contracts;
let ambix;
let source;
let sink;

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

describe('ambix', () => {
    it('should be resolved via ENS', async () => {
        await ensCheck('ambix', contracts.PublicAmbix.address);
    });

    it('static recipe', async () => {
        const accounts = await hre.ethers.getSigners();

        let resultInitial = await waiter({ func: sink.balanceOf, args: [accounts[0].address], value: 1000, retries: 50 });
        chai.expect(resultInitial).equal(1000);

        await contracts.PublicAmbix.setSink([sink.address], [1]);
        await contracts.PublicAmbix.appendSource([source.address], [10]);

        await source.transfer(accounts[0].address, 100);
        await sink.transfer(contracts.PublicAmbix.address, 100);

        let resultIntermediate = await waiter({ func: sink.balanceOf, args: [accounts[0].address], value: 900, retries: 50 });
        chai.expect(resultIntermediate).equal(resultInitial - 100);

        let sourceResult = await waiter({ func: source.balanceOf, args: [accounts[0].address], value: 100, retries: 50 });
        chai.expect(sourceResult).equal(100);

        let sinkResult = await waiter({ func: sink.balanceOf, args: [contracts.PublicAmbix.address], value: 100, retries: 50 });
        chai.expect(sinkResult).equal(100);

        await source.approve(contracts.PublicAmbix.address, 100);
        await contracts.PublicAmbix.run(0);

        let result = await waiter({ func: sink.balanceOf, args: [accounts[0].address], value: 910, retries: 50 });
        chai.expect(result - resultIntermediate).equal(10);
    });

    it('dynamic recipe', async () => {
        const accounts = await hre.ethers.getSigners();
        let resultInitial = await waiter({ func: sink.balanceOf, args: [accounts[0].address], value: 1000, retries: 50 });
        chai.expect(resultInitial).equal(1000);

        await ambix.setSink([sink.address], [0]);
        await ambix.appendSource([source.address], [0]);

        await source.transfer(accounts[0].address, 100);
        await sink.transfer(ambix.address, 1000);

        let sourceResult = await waiter({ func: source.balanceOf, args: [accounts[0].address], value: 100, retries: 50 });
        chai.expect(sourceResult).equal(100);

        let sinkResult = await waiter({ func: sink.balanceOf, args: [ambix.address], value: 1000, retries: 50 });
        chai.expect(sinkResult).equal(1000);

        await source.approve(ambix.address, 100);
        await ambix.run(0);
        let result = await waiter({ func: sink.balanceOf, args: [accounts[0].address], value: 1000, retries: 50 });
        chai.expect(result).equal(1000);
    });

    it('static recipe with KYC', async () => {
        const accounts = await hre.ethers.getSigners();

        await contracts.PublicAmbix.setSink([sink.address], [1]);
        await contracts.PublicAmbix.appendSource([source.address], [10]);

        await source.transfer(accounts[1].address, 100);
        await sink.transfer(contracts.PublicAmbix.address, 100);

        let sourceResult = await waiter({ func: source.balanceOf, args: [accounts[1].address], value: 100, retries: 50 });
        chai.expect(sourceResult).equal(100);

        let sinkResult = await waiter({ func: sink.balanceOf, args: [contracts.PublicAmbix.address], value: 100, retries: 50 });
        chai.expect(sinkResult).equal(100)

        await source.approve(contracts.PublicAmbix.address, 100, { from: accounts[1].address });

        const signature = kyc(accounts[0].address, contracts.PublicAmbix.address, accounts[1].address);
        await contracts.PublicAmbix.run(0, signature, { from: accounts[1].address });

        let result = await waiter({ func: sink.balanceOf, args: [accounts[1].address], value: 10, retries: 50 });
        chai.expect(result).equal(10);
    });

    it('dynamic recipe with KYC', async () => {
        const accounts = await hre.ethers.getSigners();

        await ambix.setSink([sink.address], [0]);
        await ambix.appendSource([source.address], [0]);

        await source.transfer(accounts[1].address, 100);
        await sink.transfer(ambix.address, 1000);
        let sourceResult = await waiter({ func: source.balanceOf, args: [accounts[1].address], value: 100, retries: 50 });
        chai.expect(sourceResult).equal(100);

        let sinkResult = await waiter({ func: sink.balanceOf, args: [contracts.PublicAmbix.address], value: 1000, retries: 50 });
        chai.expect(sinkResult).equal(1000)

        await source.approve(ambix.address, 100, { from: accounts[1].address });

        const signature = await kyc(accounts[0].address, ambix.address, accounts[1].address);

        await ambix.run(0, signature, { from: accounts[1].address });
        let result = await waiter({ func: sink.balanceOf, args: [accounts[1].address], value: 1000, retries: 50 });
        chai.expect(result).equal(1000);
    });

});
