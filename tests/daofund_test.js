const deploy = require('aira-deploy');

var Web3 = require('web3');
var web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider("http://localhost:8545"));

deploy([], true, web3, "DAOToken", ["DAO Mars colony", "DT", 0, 1000], function (daotoken) {
    console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

    deploy([], true, web3, "RewardFund", ["DAO Rewards", "DR", daotoken.address, web3.toWei(0.1, 'ether')], function (fund) {
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        // Event listening
        fund.Transfer({}, '', function(e, r) {
            console.log("[Fund] ==> Transfer("+
                r.args._from+","+r.args._to+","+r.args._value+")");
        });

        daotoken.Transfer({}, '', function(e, r) {
            console.log("[DAOToken] ==> Transfer("+
                r.args._from+","+r.args._to+","+r.args._value+")");
        });

        console.log("\n==> Setting up DAOToken <==");

        console.log("Set reward fund");
        daotoken.setRewardFund(fund.address, {from: web3.eth.accounts[0]});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        console.log("\n==> Basic reward test <==");

        console.log("Refill fund by 1 ether");
        fund.putReward({from: web3.eth.accounts[3], value: web3.toWei(1, 'ether'), gas: 200000});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        console.log("Fund.balanceOf(fund) = "+fund.balanceOf(fund.address));

        console.log("DAOToken.balanceOf("+web3.eth.accounts[0]+") = "+daotoken.balanceOf(web3.eth.accounts[0]));
        console.log("Getting reward for account "+web3.eth.accounts[0]);
        fund.getReward({from: web3.eth.accounts[0]});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        console.log("Fund.balanceOf("+web3.eth.accounts[0]+") = "+fund.balanceOf(web3.eth.accounts[0]));

        console.log("\n==> Advanced reward test <==");

        console.log("Refill fund by 1 ether");
        fund.putReward({from: web3.eth.accounts[3], value: web3.toWei(1, 'ether'), gas: 200000});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);
 
        console.log("Fund.balanceOf(fund) = "+fund.balanceOf(fund.address));

        console.log("Simple transfer DAOToken to account 1");
        daotoken.transfer(web3.eth.accounts[1], 200, {from: web3.eth.accounts[0], gas: 200000});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        console.log("Fund.balanceOf(fund) = "+fund.balanceOf(fund.address));
        console.log("DAOToken.balanceOf("+web3.eth.accounts[0]+") = "+daotoken.balanceOf(web3.eth.accounts[0]));
        console.log("Fund.balanceOf("+web3.eth.accounts[0]+") = "+fund.balanceOf(web3.eth.accounts[0]));
        console.log("DAOToken.balanceOf("+web3.eth.accounts[1]+") = "+daotoken.balanceOf(web3.eth.accounts[1]));
        console.log("Fund.balanceOf("+web3.eth.accounts[1]+") = "+fund.balanceOf(web3.eth.accounts[1]));
        console.log("Double refill fund by 1 ether");
        fund.putReward({from: web3.eth.accounts[3], value: web3.toWei(1, 'ether'), gas: 200000});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);
        fund.putReward({from: web3.eth.accounts[3], value: web3.toWei(1, 'ether'), gas: 200000});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        console.log("Fund.balanceOf(fund) = "+fund.balanceOf(fund.address));

        console.log("Simple transfer DAOToken to account 2 from 1");
        daotoken.transfer(web3.eth.accounts[2], 100, {from: web3.eth.accounts[1], gas: 200000});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);
            
        console.log("Fund.balanceOf(fund) = "+fund.balanceOf(fund.address));
        console.log("DAOToken.balanceOf("+web3.eth.accounts[0]+") = "+daotoken.balanceOf(web3.eth.accounts[0]));
        console.log("Fund.balanceOf("+web3.eth.accounts[0]+") = "+fund.balanceOf(web3.eth.accounts[0]));
        console.log("DAOToken.balanceOf("+web3.eth.accounts[1]+") = "+daotoken.balanceOf(web3.eth.accounts[1]));
        console.log("Fund.balanceOf("+web3.eth.accounts[1]+") = "+fund.balanceOf(web3.eth.accounts[1]));
        console.log("DAOToken.balanceOf("+web3.eth.accounts[2]+") = "+daotoken.balanceOf(web3.eth.accounts[2]));
        console.log("Fund.balanceOf("+web3.eth.accounts[2]+") = "+fund.balanceOf(web3.eth.accounts[2]));

        console.log("Fund.nextReward("+web3.eth.accounts[0]+") = "+fund.nextReward(web3.eth.accounts[0])); 
        console.log("Fund.nextReward("+web3.eth.accounts[1]+") = "+fund.nextReward(web3.eth.accounts[1])); 
        console.log("Fund.nextReward("+web3.eth.accounts[2]+") = "+fund.nextReward(web3.eth.accounts[2])); 

        console.log("\n==> Heavy reward test <==");

        console.log("50x refill fund by 0.1 ether");
        for (var i = 0; i < 50; ++i) {
            fund.putReward({from: web3.eth.accounts[3], value: web3.toWei(0.1, 'ether'), gas: 200000});
            console.log("Refill "+i);
            console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);
        }
 
        console.log("Simple transfer DAOToken to account 1 from 0");
        daotoken.transfer(web3.eth.accounts[1], 100, {from: web3.eth.accounts[0], gas: 4000000});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);
 
        console.log("Get rewards for account 2");
        fund.getRewards(50, {from: web3.eth.accounts[2], gas: 4000000});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        console.log("Fund.balanceOf(fund) = "+fund.balanceOf(fund.address));
        console.log("DAOToken.balanceOf("+web3.eth.accounts[0]+") = "+daotoken.balanceOf(web3.eth.accounts[0]));
        console.log("Fund.balanceOf("+web3.eth.accounts[0]+") = "+fund.balanceOf(web3.eth.accounts[0]));
        console.log("DAOToken.balanceOf("+web3.eth.accounts[1]+") = "+daotoken.balanceOf(web3.eth.accounts[1]));
        console.log("Fund.balanceOf("+web3.eth.accounts[1]+") = "+fund.balanceOf(web3.eth.accounts[1]));
        console.log("DAOToken.balanceOf("+web3.eth.accounts[2]+") = "+daotoken.balanceOf(web3.eth.accounts[2]));
        console.log("Fund.balanceOf("+web3.eth.accounts[2]+") = "+fund.balanceOf(web3.eth.accounts[2]));

        console.log("Fund.nextReward("+web3.eth.accounts[0]+") = "+fund.nextReward(web3.eth.accounts[0])); 
        console.log("Fund.nextReward("+web3.eth.accounts[1]+") = "+fund.nextReward(web3.eth.accounts[1])); 
        console.log("Fund.nextReward("+web3.eth.accounts[2]+") = "+fund.nextReward(web3.eth.accounts[2])); 

        console.log("\n==> Event log:");
    });
});
