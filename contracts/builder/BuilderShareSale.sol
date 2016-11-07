//
// AIRA Builder for ShareSale contract
//
// Ethereum address:
//  - Mainnet:
//  - Testnet: 
//

pragma solidity ^0.4.2;
import 'creator/CreatorShareSale.sol';
import './Builder.sol';

/**
 * @title ShareSale contract builder
 */
contract BuilderShareSale is Builder {
    /**
     * @dev Run script creation contract
     * @param _target is a target of funds
     * @param _etherFund is a ether wallet token
     * @param _shares is a shareholders token contract 
     * @param _price_wei is price of one share in wei
     * @return address new contract
     */
    function create(address _target, address _etherFund,
                    address _shares, uint _price_wei) returns (address) {
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
 
        var inst = CreatorShareSale.create(_target, _etherFund, _shares, _price_wei);
        getContractsOf[msg.sender].push(inst);
        Builded(msg.sender, inst);
        inst.delegate(msg.sender);
        return inst;
    }
}
