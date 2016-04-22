import 'token.sol';
import 'thesaurus.sol';

/**
 * @title Token with specification is a same as `Token` but
 *        have a permanent link to presented asset
 */
contract SpecToken is Token {
    /**
     * Token value specification
     */
    Knowledge public specification;

    /**
     * @dev SpecToken constructor
     * @param _name is a token name
     * @param _symbol is a token short name
     * @param _spec is a knowledge which present single token value 
     */
    function SpecToken(string _name, string _symbol, Knowledge _spec)
        Token(_name, _symbol) {
		specification = _spec;
    }
}
