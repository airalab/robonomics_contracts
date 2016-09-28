//
// AIRA Builder for Ambix contract
//
// Ethereum address:
//

pragma solidity ^0.4.2;
import 'creator/CreatorAmbix.sol';
import './Builder.sol';

/**
 * @title BuilderAmbix contract
 */
contract BuilderAmbix is Builder {
    /**
     * @dev Run script creation contract
     * @return address new contract
     */
    function create() returns (address) {
        var inst = CreatorAmbix.create();
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
