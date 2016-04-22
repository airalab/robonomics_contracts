import 'core.sol';
import 'token.sol';

contract ThesaurusPoll is Mortal {
    /* Operating agent storage with thesaurus */
    HumanAgentStorage agentStorage;

    /* Government shares */
    Token shares;

    /* Thesaurus term voting structure */
    struct Term {
        address[]                     voters;
        mapping(address => uint)      shareOf;
        mapping(address => Knowledge) pollOf;
    }

    /* Mapping for fast term access */
    mapping (string => Term) termOf;

    modifier termExist (string _termName) { if (termOf[_termName]) _ }

    using AddressArray for address[];

    /**
     * @dev Calc poll of target term and set thesaurus according
     *      to high vote results
     * @param _termName the name of calc term
     */
    function kingOfMountain(string _termName) private {
        var term = termOf[_termName];

        // Search the high voter
        var highVoter = voters[0];
        for (uint i = 0; i < term.voters.length; i += 1) {
            var voter = term.voters[i];
            if (term.shareOf[voter] > term.shareOf[highVoter])
                highVoter = voter;
        }
        var highKnowledge = term.pollOf[highVoter];

        // Check for knowledge already set
        if (agentStorage.getKnowledgeByName(_termName) != highKnowledge)
            agentStorage.appendKnowledgeByName(_termName, highKnowledge.copy(this));
    }

    function ThesaurusPoll(HumanAgentStorage _has, Token _shares) {
        agentStorage = _has;
        shares = _shares;
    }

    /**
     * @dev Increase poll for given term
     * @param _termName name of term
     * @param _poll knowledge presents given term
     * @param _shares how much shares given for increase
     */
    function pollUp(string _termName, Knowledge _poll, uint _shares)
            termExist(_termName) {
        var voter = msg.sender;
        var term = termOf[_termName];

        // Check shares balance
        if (shares.getBalance(voter) < _shares) throw;

        // Transfer from voter to self
        shares.transferFrom(voter, this, _shares);

        // Increase shares and set the poll
        term.shareOf[voter] += _shares;
        term.pollOf[voter]   = _poll;

        // Append voter if not in list for selected term
        if (term.voters.indexOf(voter) >= term.voters.length)
            term.voters.push(voter);

        // Call high knowledge calc procedure
        kingOfMountain(_termName);
    }

    /**
     * @dev Decrease shares for given term
     * @param _termName name of term
     * @param _shares count of shares
     */
    function pollDown(string _termName, uint _shares) termExist(_termName) {
        var voter = msg.sender;
        var term = termOf[_termName];

        var refund = term.shareOf[voter] > _shares ? _shares : term.shareOf[voter];

        shares.transfer(voter, refund);
        term.shareOf[voter] -= refund;

        kingOfMountain(_termName);
    }
}
