import 'thesaurus/KnowledgeStorage.sol';
import 'token/Token.sol';
import 'lib/Voting.sol';

contract DAOKnowledgeStorage is Mortal {
    /* Operating agent storage with thesaurus */
    KnowledgeStorage public thesaurus;

    /* Government shares */
    Token public shares;

    /* Mapping for fast term access */
    mapping(string => Voting.Poll) termOf;
    using Voting for Voting.Poll;
    
    function DAOKnowledgeStorage(address _thesaurus, address _shares) {
        thesaurus = KnowledgeStorage(_thesaurus);
        shares    = Token(_shares);
    }

    /**
     * @dev Calc poll of target term and set thesaurus according
     *      to high vote results
     * @param _termName the name of calc term
     */
    function update(string _termName) internal {
        var term = termOf[_termName];

        // Check for knowledge already set
        var current = Knowledge(term.current());
        if (thesaurus.get(_termName) != current)
            thesaurus.set(_termName, current);
    }

    /**
     * @dev Increase poll for given term
     * @param _termName name of term
     * @param _value knowledge presents given term
     * @param _count how much shares given for increase
     * @notice Given knownledge should be delegated to me
     */
    function pollUp(string _termName, Knowledge _value, uint _count) {
        // So throw when knowledge is not my 
        if (_value.owner() != address(this)) return;

        // Poll up given term name
        var voter = msg.sender;
        var term = termOf[_termName];
        term.up(voter, _value, shares, _count);

        // Update thesaurus term
        update(_termName);
    }

    /**
     * @dev Decrease shares for given term
     * @param _termName name of term
     * @param _count count of refunded shares
     */
    function pollDown(string _termName, uint _count) {
        // Poll down given term name
        var voter = msg.sender;
        var term = termOf[_termName];
        term.down(voter, shares, _count);

        // Update thesaurus term
        update(_termName);
    }
}
