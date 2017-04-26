pragma solidity ^0.4.4;
import 'common/Object.sol';
import 'common/Observer.sol';
import './DAOToken.sol';

/* The democracy contract itself */
contract Association is Object, Observer {
    /* Contract Variables and events */
    uint        public minimumQuorum;
    uint        public debatingPeriodInMinutes;
    Proposal[]  public proposals;
    uint        public numProposals;
    DAOToken    public daoTokenAddress;

    // Map of addresses and proposal voted on by this address
    mapping(address => uint[]) public votingOf;

    event ProposalAdded(uint proposalID, address recipient, uint amount, string description);
    event Voted(uint proposalID, bool position, address voter);
    event ProposalTallied(uint proposalID, uint quorum, bool active);
    event ChangeOfRules(uint minimumQuorum, uint debatingPeriodInMinutes, address daoTokenAddress);

    struct Proposal {
        address recipient;
        uint    amount;
        string  description;
        uint    votingDeadline;
        bool    executed;
        bool    proposalPassed;
        bytes32 proposalHash;
        uint    yea;
        uint    nay;
        mapping(address => bool) voted;
        mapping(address => bool) supportsProposal;
    }

    struct Vote {
        bool inSupport;
        address voter;
    }

    /* modifier that allows only shareholders to vote and create new proposals */
    modifier onlyShareholders {
        if (daoTokenAddress.balanceOf(msg.sender) == 0) throw;
        _;
    }

    /* First time setup */
    function Association(address tokenAddress, uint minimumSharesToPassAVote, uint minutesForDebate) payable {
        changeVotingRules(DAOToken(tokenAddress), minimumSharesToPassAVote, minutesForDebate);
    }

    /*change rules*/
    function changeVotingRules(DAOToken tokenAddress, uint minimumSharesToPassAVote, uint minutesForDebate) onlyOwner {
        daoTokenAddress = tokenAddress;
        if (minimumSharesToPassAVote == 0 ) minimumSharesToPassAVote = 1;
        minimumQuorum = minimumSharesToPassAVote;
        debatingPeriodInMinutes = minutesForDebate;
        ChangeOfRules(minimumQuorum, debatingPeriodInMinutes, daoTokenAddress);
    }

    /* Function to create a new proposal */
    function newProposal(
        address beneficiary,
        uint weiAmount,
        string JobDescription,
        bytes transactionBytecode
    )
        onlyShareholders
        returns (uint proposalID)
    {
        proposalID = proposals.length++;
        Proposal p = proposals[proposalID];
        p.recipient = beneficiary;
        p.amount = weiAmount;
        p.description = JobDescription;
        p.proposalHash = sha3(beneficiary, weiAmount, transactionBytecode);
        p.votingDeadline = now + debatingPeriodInMinutes * 1 minutes;
        p.executed = false;
        p.proposalPassed = false;
        ProposalAdded(proposalID, beneficiary, weiAmount, JobDescription);
        numProposals = proposalID+1;
    }

    /* function to check if a proposal code matches */
    function checkProposalCode(
        uint proposalNumber,
        address beneficiary,
        uint etherAmount,
        bytes transactionBytecode
    )
        constant
        returns (bool codeChecksOut)
    {
        Proposal p = proposals[proposalNumber];
        return p.proposalHash == sha3(beneficiary, etherAmount, transactionBytecode);
    }

    /* */
    function vote(uint proposalNumber, bool supportsProposal)
        onlyShareholders
    {
        Proposal p = proposals[proposalNumber];
        var balance = daoTokenAddress.balanceOf(msg.sender);
        if (p.voted[msg.sender] == true || balance == 0) throw;

        p.voted[msg.sender]            = true;
        p.supportsProposal[msg.sender] = supportsProposal;
        if (supportsProposal) {
            p.yea += balance;
        } else {
            p.nay += balance;
        }

        votingOf[msg.sender].push(proposalNumber);
        Voted(proposalNumber, supportsProposal, msg.sender);
    }

    function unVote(uint proposalNumber) {
        Proposal p = proposals[proposalNumber];
        var balance = daoTokenAddress.balanceOf(msg.sender);
        if (!p.voted[msg.sender] || balance == 0) throw;

        if (now < p.votingDeadline) {
            if (p.supportsProposal[msg.sender]) {
                p.yea -= balance;
            } else {
                p.nay -= balance;
            }
            p.voted[msg.sender] = false;
        }

        var voting = votingOf[msg.sender];
        if (voting.length > 1) {
            uint i = 0;
            while (proposalNumber != voting[i++]) {}
            voting[i] = voting[voting.length - 1];
            voting.length -= 1;
        } else {
            voting.length = 0;
        }
    }

    function executeProposal(uint proposalNumber, bytes transactionBytecode) returns (int result) {
        Proposal p = proposals[proposalNumber];
        /* Check if the proposal can be executed */
        if (now < p.votingDeadline  /* has the voting deadline arrived? */
            ||  p.executed        /* has it been already executed? */
            ||  p.proposalHash != sha3(p.recipient, p.amount, transactionBytecode)) /* Does the transaction code match the proposal? */
            throw;

        var quorum = p.yea + p.nay;

        /* execute result */
        if (quorum <= minimumQuorum) {
            /* Not enough significant voters */
            throw;
        } else if (p.yea > p.nay ) {
            /* has quorum and was approved */
            p.executed = true;
            if (!p.recipient.call.value(p.amount)(transactionBytecode)) throw;
            p.proposalPassed = true;
        } else {
            p.proposalPassed = false;
        }
        // Fire Events
        ProposalTallied(proposalNumber, quorum, p.proposalPassed);
    }

    /**
     * @dev Observer interface
     */
    function eventHandle(uint _event, bytes32[] _data) returns (bool) {
        if (msg.sender != address(daoTokenAddress)) throw;

        if (_event == 0x10) { // TRANSFER_EVENT
            address from = address(_data[0]);
            address to   = address(_data[1]);

            // Check for no voting process is active
            if (votingOf[from].length > 0 || votingOf[to].length > 0)
                throw;
        }
        return true;
    }

    function () payable {}
}
