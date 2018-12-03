const Lighthouse = artifacts.require("Lighthouse");
const Factory = artifacts.require("Factory");
const ENS = artifacts.require("ENS");
const XRT = artifacts.require("XRT");
const fs = require('fs');

module.exports = (deployer, network, accounts) => {

    if (network === 'testing') {
        deployer.then(async () => {
            fs.writeFile('ENS.address', web3.utils.toChecksumAddress(ENS.address),
                err => { if (err) throw err; else console.log('Saved ENS.address!'); }
            ); 

            fs.writeFile('XRT.address', web3.utils.toChecksumAddress(XRT.address),
                err => { if (err) throw err; else console.log('Saved XRT.address!'); }
            );

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
