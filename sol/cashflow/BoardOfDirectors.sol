import 'creator/CreatorCoreModify.sol';
import 'creator/CreatorVoting51.sol';
import 'lib/Voting.sol';

contract BoardOfDirectorsFund {
    address public target;
    uint    public value; 

    function BoardOfDirectorsFund(address _target, uint _value) {
        target = _target;
        value  = _value;
    }
}

contract BoardOfDirectors is Owned, ProposalDoneReceiver {
    Core     public dao_core;
    Token    public shares;
    Token    public credits;
    Voting51 public voting;

    Voting.Poll voting_token;
    using Voting for Voting.Poll;

    event VotingTokenChanged(address indexed new_token);

    /**
     * @dev Board of directors constructor
     * @param _dao_core is a DAO core register
     * @param _shares is a share holders token
     * @param _credits is a fund token
     */
    function BoardOfDirectors(address _dao_core, address _shares, address _credits) {
        dao_core = Core(_dao_core);
        shares   = Token(_shares);
        credits  = Token(_credits);
    }

    modifier onlyDirectors {
        if (address(voting) != 0 && voting.voting_token().balanceOf(msg.sender) > 0) _
    }

    enum ProposalType {
        CoreModify,
        Fund
    }

    mapping(address => ProposalType) typeOf;

    /**
     * @dev Make a proposal for remove module from DAO register
     * @param _name is a module name
     * @param _description is a proposal description
     * @param _start_time is start time of voting
     * @param _duration_sec is duration of voting
     */
    function removeCoreModule(string _name, string _description,
                              uint _start_time, uint _duration_sec) onlyDirectors {
        if (address(voting) == 0) throw;

        var mod = CreatorCoreModify.create(dao_core);
        typeOf[mod] = ProposalType.CoreModify;
        mod.removeModule(_name);
        voting.proposal(mod, _description, _start_time, _duration_sec);
    }

    /**
     * @dev Make a proposal for set new module for the DAO register 
     * @param _name is a module name
     * @param _module is a module address
     * @param _interface is a link for module interface
     * @param _constant is a flag for constant modules
     * @param _description is a proposal description
     * @param _start_time is start time of voting
     * @param _duration_sec is duration of voting
     */
    function setCoreModule(string _name, address _module,
                           string _interface, bool _constant,
                           string _description,
                           uint _start_time, uint _duration_sec) onlyDirectors {
        if (address(voting) == 0) throw;

        var mod = CreatorCoreModify.create(dao_core);
        typeOf[mod] = ProposalType.CoreModify;
        mod.setModule(_name, _module, _interface, _constant);
        voting.proposal(mod, _description, _start_time, _duration_sec);
    }

    /**
     * @dev Make a proposal for funding address
     * @param _target is a target of fund
     * @param _value is a value of fund
     * @param _description is a proposal description
     * @param _start_time is start time of voting
     * @param _duration_sec is duration of voting
     */
    function fund(address _target, uint _value,
                  string _description, uint _start_time, uint _duration_sec) onlyDirectors {
        if (address(voting) == 0) throw;

        var bod_fund = new BoardOfDirectorsFund(_target, _value);
        typeOf[bod_fund] = ProposalType.Fund;
        voting.proposal(bod_fund, _description, _start_time, _duration_sec);
    }

    /**
     * @dev Service callback function for proposal done tracking
     */
    function proposalDone(uint _index) {
        if (msg.sender != address(voting)) throw;

        var proposal = voting.proposal_target(_index);
        if (typeOf[proposal] == ProposalType.CoreModify) {
            dao_core.delegate(proposal);
            Modify(proposal).run();
        } else {
            if (typeOf[proposal] == ProposalType.Fund) {
                var bod_fund = BoardOfDirectorsFund(proposal);
                if (!credits.transfer(bod_fund.target(), bod_fund.value()))
                    throw;
            }
        }
    }
 
    /**
     * @dev Vote for the new directors token
     * @param _new_voting is a new voting token
     * @param _count is a count of shares
     * @notice shares should be approved for this contract
     */
    function pollUp(Token _new_voting, uint _count) {
        voting_token.up(msg.sender, _new_voting, shares, _count);
        checkVotingToken();
    }
    
    /**
     * @dev Refund shares
     * @param _count is a count of refunded shares
     */
    function pollDown(uint _count) {
        voting_token.down(msg.sender, shares, _count);
        checkVotingToken();
    }

    function checkVotingToken() private {
        if (address(voting) == 0) throw;

        if ( voting.voting_token() != voting_token.current()
          && voting_token.valueOf[voting_token.current()] > shares.totalSupply() / 2) {
                voting = CreatorVoting51.create(Token(voting_token.current()), this);
                VotingTokenChanged(voting_token.current());
        }
    }
}
