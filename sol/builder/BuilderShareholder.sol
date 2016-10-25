//
// AIRA Builder for Shareholder contract
//
// Ethereum address:
//  - Mainnet:
//  - Testnet: 
//

pragma solidity ^0.4.2;
import 'creator/CreatorShareholder.sol';
import './Builder.sol';

/**
 * @title BuilderShareholder contract
 */
contract BuilderShareholder is Builder {
    /**
     * @dev Run script creation contract
     * @param _shares is a shares token address
     * @param _count is a count of shares for transfer
     * @param _recipient is a shares recipient
     * @return address new contract
     */
    function create(string _desc, address _shares, uint _count, address _recipient) returns (address) {
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
 
        var inst = CreatorShareholder.create(_desc, _shares, _count, _recipient);
        getContractsOf[msg.sender].push(inst);
        Builded(msg.sender, inst);
        inst.delegate(msg.sender);
        return inst;
    }
}
