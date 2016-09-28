//
// AIRA Builder for TokenEther contract
//
// Ethereum address:
//

pragma solidity ^0.4.2;
import 'creator/CreatorTokenEther.sol';
import './Builder.sol';

/**
 * @title BuilderTokenEther contract
 */
contract BuilderTokenEther is Builder {
    /**
     * @dev Run script creation contract
     * @param _name is name token
     * @param _symbol is symbol token
     * @return address new contract
     */
    function create(string _name, string _symbol) returns (address) {
        var inst = CreatorTokenEther.create(_name, _symbol);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
