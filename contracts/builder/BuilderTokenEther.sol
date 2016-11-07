//
// AIRA Builder for TokenEther contract
//
// Ethereum address:
//  - Mainnet:
//  - Testnet: 
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
 
        var inst = CreatorTokenEther.create(_name, _symbol);
        getContractsOf[msg.sender].push(inst);
        Builded(msg.sender, inst);
        inst.delegate(msg.sender);
        return inst;
    }
}
