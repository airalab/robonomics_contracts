const hre = require("hardhat");
const { ensCheck, kyc } = require('./helpers/helpers')
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
    // const [deployer] = await hre.ethers.getSigners();

    // source = await deployments.deploy('XRT', {
    //     from: deployer.address,
    //     args: [100],
    //     log: true,
    // });
    
    // sink = await deployments.deploy('XRT', {
    //     from: deployer.address,
    //     args: [1000],
    //     log: true,
    // });

    // const Token = await ethers.getContractFactory('XRT');
    // source = await Token.deploy(100);

    // const Token2 = await ethers.getContractFactory('XRT');
    // sink = await Token2.deploy(1000);

    await deployments.fixture();
    contracts.ambix = await ethers.getContract('PublicAmbix');
});

describe('ambix', () => {
    it('should be resolved via ENS', async () => {
        await ensCheck('ambix', contracts.PublicAmbix.address);
    });

    it('static recipe', async () => {
        const accounts = await hre.ethers.getSigners();
        source = await deployments.deploy('XRT', {
            from: accounts[0].address,
            args: [100],
            log: true,
        });
        
        sink = await deployments.deploy('XRT', {
            from: accounts[0].address,
            args: [1000],
            log: true,
        });

        await contracts.PublicAmbix.setSink([sink.address], [3]);
        await contracts.PublicAmbix.appendSource([source.address], [10]);

        await source.transfer(accounts[1].address, 100);
        await sink.transfer(contracts.PublicAmbix.address, 100);

        await source.approve(contracts.PublicAmbix.address, 100, { from: accounts[1].address });
        await contracts.PublicAmbix.run(0, { from: accounts[1].address });

        chai.expect((await sink.balanceOf(accounts[1].address)).toNumber()).equal(30);

        await new Promise((resolve) => { resolve(); return; });
    });

    it('dynamic recipe', async () => {
        await new Promise((resolve) => setTimeout(resolve, 10000));
        const accounts = await hre.ethers.getSigners();
        await ambix.setSink([sink.address], [0]);
        await ambix.appendSource([source.address], [0]);

        await source.transfer(accounts[1].address, 100);
        await sink.transfer(ambix.address, 1000);

        await source.approve(ambix.address, 100, { from: accounts[1].address });
        await ambix.run(0, { from: accounts[1].address });

        chai.expect((await sink.balanceOf(accounts[1].address)).toNumber()).equal(1000);
    });

    it('static recipe with KYC', async () => {
        const accounts = await hre.ethers.getSigners();
        await contracts.PublicAmbix.setSink([sink.address], [1]);
        await contracts.PublicAmbix.appendSource([source.address], [10]);

        await source.transfer(accounts[1].address, 100);
        await sink.transfer(contracts.PublicAmbix.address, 100);

        await source.approve(contracts.PublicAmbix.address, 100, { from: accounts[1].address });

        const signature = kyc(web3, kyc_account, contracts.PublicAmbix.address, accounts[1].address);
        await contracts.PublicAmbix.run(0, signature, { from: accounts[1].address });

        chai.expect((await sink.balanceOf(accounts[1].address)).toNumber()).equal(10);
    });

    it('dynamic recipe with KYC', async () => {
        const accounts = await hre.ethers.getSigners();
        await ambix.setSink([sink.address], [0]);
        await ambix.appendSource([source.address], [0]);

        await source.transfer(accounts[1].address, 100);
        await sink.transfer(ambix.address, 1000);
        await source.approve(ambix.address, 100, { from: accounts[1].address });

        const signature = await kyc(web3, kyc_account, ambix.address, accounts[1].address);
        await ambix.run(0, signature, { from: accounts[1].address });
        chai.expect((await sink.balanceOf(accounts[1].address)).toNumber()).equal(1000);
    });

});
