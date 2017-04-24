const deploy = require('aira-deploy');

var Web3 = require('web3');
var web3 = new Web3();
web3.setProvider(new web3.providers.HttpProvider("http://localhost:8545"));

deploy([], true, web3, "DAOToken", ["DAO Mars colony", "DT", 0, 1000], function (daotoken) {
    console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

    deploy([], true, web3, "Association", [daotoken.address, 501, 1], function (association) {
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        // Event listening
        daotoken.Transfer({}, '', function(e, r) {
            console.log("[DAOToken] ==> Transfer("+
                r.args._from+","+r.args._to+","+r.args._value+")");
        });

        console.log("\n==> Setting up DAOToken <==");

        console.log("Set association");
        daotoken.setAssociation(association.address, {from: web3.eth.accounts[0]});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        console.log("Transfer 5 ether to association");
        web3.eth.sendTransaction({from: web3.eth.accounts[3], to: association.address, value: web3.toWei(5, 'ether')});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        console.log("association.balance = "+web3.eth.getBalance(association.address));

        console.log("\n==> Basic association test <==");

        console.log("Making new proposal");
        association.newProposal(web3.eth.accounts[3], web3.toWei(1, 'ether'), "contract creation", "", {from: web3.eth.accounts[0], gas: 2000000});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        console.log("association.proposal(0) = "+association.proposals(0));

        console.log("Voting Yes from account 0");
        association.vote(0, true, {from: web3.eth.accounts[0], gas: 2000000});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        console.log("association.proposal(0) = "+association.proposals(0));

        try {
            console.log("Try to transfer DAOToken to account 1");
            daotoken.transfer(web3.eth.accounts[1], 300, {from: web3.eth.accounts[0], gas: 4000000});
        } catch (e) {
            console.log("Transfer pretty fail! "+e);
        }

        console.log("Account 0 should unvote, do it");
        association.unVote(0, {from: web3.eth.accounts[0], gas: 2000000})
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        console.log("association.proposal(0) = "+association.proposals(0));
        
        console.log("Try to transfer DAOToken to account 1");
        daotoken.transfer(web3.eth.accounts[1], 300, {from: web3.eth.accounts[0], gas: 4000000});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        console.log("Try to transfer DAOToken to account 2");
        daotoken.transfer(web3.eth.accounts[2], 300, {from: web3.eth.accounts[0], gas: 4000000});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        console.log("\n==> Advanced association test <==");

        console.log("Vote Yes proposal from account 2");
        association.vote(0, true, {from: web3.eth.accounts[2], gas: 2000000});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        console.log("association.proposal(0) = "+association.proposals(0));

        try {
            console.log("Try to execute proposal")
            association.executeProposal(0, "", {from: web3.eth.accounts[2], gas: 4000000});
        } catch (e) {
            console.log("Execution pretty fail! "+e);
        }

        console.log("Vote Yes proposal from accounts 1 too");
        association.vote(0, true, {from: web3.eth.accounts[1], gas: 2000000});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        console.log("association.proposal(0) = "+association.proposals(0));

        console.log("Sleeping for proposal deadline...");
        while (Math.floor(Date.now() / 1000) < association.proposals(0)[3]);
        console.log("Wakeup!");

        console.log("Try to execute proposal")
        association.executeProposal(0, "", {from: web3.eth.accounts[2], gas: 4000000});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        console.log("association.proposal(0) = "+association.proposals(0));

        console.log("Making new proposal 1");
        association.newProposal(web3.eth.accounts[3], web3.toWei(1, 'ether'), "contract creation", "", {from: web3.eth.accounts[0], gas: 2000000});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        console.log("association.proposal(1) = "+association.proposals(1));

        console.log("Vote No proposal from accounts 0");
        association.vote(1, false, {from: web3.eth.accounts[0], gas: 2000000});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        console.log("association.proposal(1) = "+association.proposals(1));

        console.log("Vote No proposal from accounts 1");
        association.vote(1, false, {from: web3.eth.accounts[1], gas: 2000000});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        console.log("association.proposal(1) = "+association.proposals(1));

        console.log("Vote Yes proposal from accounts 2");
        association.vote(1, true, {from: web3.eth.accounts[2], gas: 2000000});
        console.log("==> gas " + web3.eth.getBlock("pending").gasUsed);

        console.log("association.proposal(1) = "+association.proposals(1));

        console.log("Sleeping for proposal deadline...");
        while (Math.floor(Date.now() / 1000) < association.proposals(1)[3]);
        console.log("Wakeup!");

        console.log("Try to execute proposal 1")
        association.executeProposal(1, "", {from: web3.eth.accounts[2], gas: 4000000});

        console.log("association.proposal(1) = "+association.proposals(1));
    });
});
