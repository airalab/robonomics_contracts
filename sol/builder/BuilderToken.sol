//
// AIRA Builder for Token contract
//
// Ethereum address:
//

pragma solidity ^0.4.2;
import 'creator/CreatorToken.sol';
import './Builder.sol';

/**
 * @title BuilderToken contract
 */
contract BuilderToken is Builder {
    /**
     * @dev Run script creation contract
     * @param _name is name token
     * @param _symbol is symbol token
     * @param _decimals is fixed point position
     * @param _count is count of tokens exist
     * @return address new contract
     */
    function create(string _name, string _symbol, uint8 _decimals, uint256 _count) returns (address) {
        var inst = CreatorToken.create(_name, _symbol, _decimals, _count);
        inst.transfer(msg.sender, _count);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
