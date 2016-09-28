//
// AIRA Builder for ACLStorage contract
//
// Ethereum address:
//  - Testnet: 
//

pragma solidity ^0.4.2;
import 'creator/CreatorACLStorage.sol';
import './Builder.sol';

/**
 * @title BuilderACLStorage contract
 */
contract BuilderACLStorage is Builder {
    /**
     * @dev Run script creation contract
     * @return address new contract
     */
    function create() returns (address) {
        var inst = CreatorACLStorage.create();
        Owned(inst).delegate(msg.sender);

        deal(inst);
        return inst;
    }
}
