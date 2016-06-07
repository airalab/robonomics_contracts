import './TokenEmission.sol';
import 'thesaurus/Knowledge.sol';

/**
 * @title Token with specification is a same as `Token` but
 *        have a permanent link to presented asset
 */
contract TokenSpec is TokenEmission {
    /**
     * Token value specification
     */
    Knowledge public specification;

    /**
     * @dev SpecToken constructor
     * @param _name is a token name
     * @param _symbol is a token short name
     * @param _count is a start count of tokens
     * @param _decimals is a fixed point position
     * @param _spec is a knowledge which present single token value 
     */
    function TokenSpec(string _name, string _symbol, uint8 _decimals,
                       uint _count, address _spec)
             TokenEmission(_name, _symbol, _decimals, _count) {
        specification = Knowledge(_spec);
    }
}
