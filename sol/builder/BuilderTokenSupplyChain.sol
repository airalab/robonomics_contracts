//
// AIRA Builder for TokenSupplyChain contract
//
// Ethereum address:
//

pragma solidity ^0.4.2;
import 'creator/CreatorTokenSupplyChain.sol';
import './Builder.sol';

/**
 * @title BuilderTokenSupplyChain contract
 */
contract BuilderTokenSupplyChain is Builder {
    /**
     * @dev Run script creation contract
     * @param _name is name token
     * @param _symbol is symbol token
     * @param _decimals is fixed point position
     * @return address new contract
     */
    function create(string _name, string _symbol, uint8 _decimals) returns (address) {
        var inst = CreatorTokenSupplyChain.create(_name, _symbol, _decimals);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
