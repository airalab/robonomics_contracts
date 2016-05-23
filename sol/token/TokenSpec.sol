import './Token.sol';
import 'thesaurus/Knowledge.sol';

/**
 * @title Token with specification is a same as `Token` but
 *        have a permanent link to presented asset
 */
contract TokenSpec is Token {
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
    function TokenSpec(string _name, string _symbol, address _spec)
        Token(_name, _symbol) { specification = Knowledge(_spec); }
}
