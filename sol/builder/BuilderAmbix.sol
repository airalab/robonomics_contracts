//
// AIRA Builder for Ambix contract
//
// Ethereum address:
//  - Mainnet:
//  - Testnet: 
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
        if (buildingCostWei > 0 && beneficiary != 0) {
            // Too low value
            if (msg.value < buildingCostWei) throw;
            // Beneficiary send
            if (!beneficiary.send(buildingCostWei)) throw;
            // Refund
            if (!msg.sender.send(msg.value - buildingCostWei)) throw;
        } else {
            // Refund all
            if (msg.value > 0) {
                if (!msg.sender.send(msg.value)) throw;
            }
        }
 
        var inst = CreatorAmbix.create();
        getContractsOf[msg.sender].push(inst);
        Builded(msg.sender, inst);
        inst.delegate(msg.sender);
        return inst;
    }
}
