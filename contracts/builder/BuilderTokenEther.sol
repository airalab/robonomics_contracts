//
// AIRA Builder for TokenEther contract
//
// Ethereum address:
//  - Mainnet:
//  - Testnet: 
//

pragma solidity ^0.4.4;
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
     * @param _client is a contract destination address (zero for sender)
     * @return address new contract
     */
    function create(string _name, string _symbol, address _client) payable returns (address) {
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
 
        var inst = CreatorTokenEther.create(_name, _symbol);
        getContractsOf[_client].push(inst);
        Builded(_client, inst);
        inst.setOwner(_client);
        inst.setHammer(_client);
        return inst;
    }
}
