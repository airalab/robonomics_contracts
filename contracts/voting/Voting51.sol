pragma solidity ^0.4.4;
import 'common/Object.sol'; 
import 'token/Token.sol'; 

contract ProposalDoneReceiver {
    function proposalDone(uint _index);
}

/**
 * @dev The 51% voting
 */
contract Voting51 is Object {
    Token                public voting_token;
    ProposalDoneReceiver public receiver;

    address[]               public proposal_target;
    mapping(uint => uint)   public start_time;
    mapping(uint => uint)   public end_time;
    mapping(uint => string) public description;

    mapping(uint => uint)   public total_value;
    mapping(uint => mapping(address => uint)) public voter_value;

    uint public current_proposal = 0;

    event ProposalDone(uint indexed index);
    event ProposalNew(uint indexed index);

    /**
     * @dev Create voting contract for given voting token
     * @param _voting_token is a token used for voting actions
     * @param _receiver is a receiver for proposal done actions
     */
    function Voting51(address _voting_token, address _receiver) {
        voting_token = Token(_voting_token);
        receiver     = ProposalDoneReceiver(_receiver);
    }

    /**
     * @dev Append new proposal for voting
     * @param _target is a proposal target
     * @param _description is a proposal description
     * @param _start_time is a start time of voting
     * @param _duration_sec is a duration of voting
     * @notice only voters (accounts with positive voting token balance) can call it
     */
    function proposal(address _target, string _description,
                      uint _start_time, uint _duration_sec) onlyOwner {
        description[proposal_target.length] = _description;
        start_time[proposal_target.length]  = _start_time;
        end_time[proposal_target.length]    = _start_time + _duration_sec;
        proposal_target.push(_target);
        ProposalNew(proposal_target.length-1);
    }

    /**
     * @dev Voting for current proposal
     * @param _count is how amount of `voting_token` used
     * @notice `voting_token` should be approved for voting
     */
    function vote(uint _count) {
        // Check for no proposal exist
        if (proposal_target[current_proposal] == 0
         || now < start_time[current_proposal]) throw;

        // Check for end of voting time
        if (now > end_time[current_proposal]) {
            ++current_proposal;
            return;
        }

        // Thransfer token
        if (!voting_token.transferFrom(msg.sender, this, _count)) throw;

        // Increment values
        total_value[current_proposal]             += _count;
        voter_value[current_proposal][msg.sender] += _count;

        var voting_limit = voting_token.totalSupply() / 2; // 50%
        // Check vote done
        if (total_value[current_proposal] > voting_limit) {
            ProposalDone(current_proposal);
            receiver.proposalDone(current_proposal++);
        }
    }

    /**
     * @dev Refund voting tokens
     * @param _proposal is a proposal id
     * @param _count is how amount of tokens should be refunded
     */
    function refund(uint _proposal, uint _count) {
        if (voter_value[_proposal][msg.sender] < _count) throw;
        if (!voting_token.transfer(msg.sender, _count)) throw;
        voter_value[_proposal][msg.sender] -= _count;
    }
}
