//
// AIRA Builder for Association contract
//
// Ethereum address:
//  - Mainnet:
//  - Testnet: 
//

pragma solidity ^0.4.4;
import 'creator/CreatorAssociation.sol';
import './Builder.sol';

/**
 * @title BuilderAssociation contract
 */
contract BuilderAssociation is Builder {
    /**
     * @dev Run script creation contract
     * @return address new contract
     */
    function create(address sharesAddress,
                    uint256 minimumSharesToPassAVote,
                    uint256 minutesForDebate,
                    address _client) payable returns (address) {
        if (buildingCostWei > 0 && beneficiary != 0) {
            // Too low value
            if (msg.value < buildingCostWei) throw;
            // Beneficiary send
            if (!beneficiary.send(buildingCostWei)) throw;
            // Refund
            if (msg.value > buildingCostWei) {
                if (!msg.sender.send(msg.value - buildingCostWei)) throw;
            }
        } else {
            // Refund all
            if (msg.value > 0) {
                if (!msg.sender.send(msg.value)) throw;
            }
        }

        if (_client == 0)
            _client = msg.sender;
 
        var inst = CreatorAssociation.create(sharesAddress,
                                             minimumSharesToPassAVote,
                                             minutesForDebate);
        getContractsOf[_client].push(inst);
        Builded(_client, inst);
        inst.setOwner(_client);
        inst.setHammer(_client);
        return inst;
    }
}
