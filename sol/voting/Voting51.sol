import 'common/Owned.sol'; 
import 'token/Token.sol'; 

contract ProposalTarget {
    function targetDone();
}

/**
 * @dev The 51% voting
 */
contract Voting51 is Owned {
    Token public shares;
    uint  public voting_limit;

    address[]               public proposal;
    mapping(uint => uint)   public start_time;
    mapping(uint => string) public description;

    mapping(uint => uint)   public total_value;
    mapping(uint => mapping(address => uint)) public voter_value;

    uint public current_proposal = 0;

    event ProposalDone(uint indexed proposal);

    function Voting51(Token _shares) {
        shares = _shares;
    }

    /**
     * @dev Append new proposal for voting
     * @param _target is a proposal target
     * @param _description is a proposal description
     */
    function appendProposal(address _target,
                            string _description,
                            uint _start_time) onlyOwner {
        description[proposal.length] = _description;
        start_time[proposal.length]  = _start_time;
        proposal.push(_target);
    }

    /**
     * @dev Voting for current proposal
     * @param _count is how amount of shares used
     * @notice shares should be approved for voting
     */
    function vote(uint _count) {
        // Check for no proposal exist
        if (proposal[current_proposal] == 0
         || now < start_time[current_proposal]) throw;

        // Voting operation
        if (shares.transferFrom(msg.sender, this, _count)) {
            total_value[current_proposal]             += _count;
            voter_value[current_proposal][msg.sender] += _count;

            var voting_limit = shares.totalSupply() / 2;
            // Check vote done
            if (total_value[current_proposal] > voting_limit) {
                ProposalTarget(proposal[current_proposal]).targetDone();
                ProposalDone(current_proposal);
                ++current_proposal;
            }
        }
    }

    /**
     * @dev Refund shares
     * @param _proposal is a proposal id
     * @param _count is how amount of shares should be refunded
     */
    function refund(uint _proposal, uint _count) {
        if (voter_value[_proposal][msg.sender] >= _count)
            shares.transfer(msg.sender, _count);
    }
}
