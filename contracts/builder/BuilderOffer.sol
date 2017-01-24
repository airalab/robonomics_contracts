//
// AIRA Builder for Offer contract
//
// Ethereum address:
//  - Mainnet:
//  - Testnet: 
//

pragma solidity ^0.4.4;
import 'creator/CreatorOffer.sol';
import './Builder.sol';

/**
 * @title BuilderOffer contract
 */
contract BuilderOffer is Builder {
    /**
     * @dev Run script creation contract
     * @param _description is a short description
     * @param _token is a offer token
     * @param _value is a count of tokens for transfer
     * @param _beneficiary is a offer recipient
     * @param _hard_offer is a hard offer address
     * @param _client is a contract destination address (zero for sender)
     * @return address new contract
     */
    function create(string _description, address _token, uint _value,
                    address _beneficiary, address _hard_offer, address _client) payable returns (address) {
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
 
        var inst = CreatorOffer.create(_description, _token, _value,
                                       _beneficiary, _hard_offer);
        getContractsOf[_client].push(inst);
        Builded(_client, inst);
        inst.setOwner(_client);
        inst.setHammer(_client);
        return inst;
    }
}
