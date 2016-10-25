//
// AIRA Builder for Core contract
//
// Ethereum address:
//  - Mainnet:
//  - Testnet: 
//

pragma solidity ^0.4.2;
import 'creator/CreatorCore.sol';
import './Builder.sol';

/**
 * @title BuilderCore contract
 */
contract BuilderCore is Builder {
    /**
     * @dev Run script creation contract
     * @param _name is DAO name
     * @param _description is DAO description
     * @return address new contract
     */
    function create(string _name, string _description) payable returns (address) {
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
 
        var inst = CreatorCore.create(_name, _description);
        getContractsOf[msg.sender].push(inst);
        Builded(msg.sender, inst);
        inst.delegate(msg.sender);
        return inst;
    }
}
