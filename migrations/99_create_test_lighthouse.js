const Lighthouse = artifacts.require("Lighthouse");
const Factory = artifacts.require("Factory");
const ENS = artifacts.require("ENS");
const XRT = artifacts.require("XRT");

module.exports = (deployer, network, accounts) => {

    if (network === 'testing') {
        deployer.then(async () => {

            const factory = await Factory.deployed();
            const xrt = await XRT.deployed();
            const tx = await factory.createLighthouse(1000, 10, "test");
            const lighthouse = await Lighthouse.at(tx.logs[0].args.lighthouse);
            await xrt.approve(lighthouse.address,1000);
            await xrt.allowance(accounts[0],lighthouse.address);
            await lighthouse.refill(1000);
            await xrt.approve(factory.address, 1000);
        });
    }

};
