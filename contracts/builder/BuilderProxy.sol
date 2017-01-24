//
// AIRA Builder for Proxy contract
//
// Ethereum address:
//  - Mainnet:
//  - Testnet: 
//

pragma solidity ^0.4.4;
import 'creator/CreatorProxy.sol';
import './Builder.sol';

/**
 * @title BuilderProxy contract
 */
contract BuilderProxy is Builder {
    /**
     * @dev Run script creation contract
     * @param _ident Proxy account default identifier
     * @param _client Proxy owner address
     * @return address new contract
     */
    function create(bytes32 _ident, address _safe, address _client) payable returns (address) {
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
 
        var inst = CreatorProxy.create(_client, _ident, _safe);
        getContractsOf[_client].push(inst);
        Builded(_client, inst);
        inst.setOwner(_client);
        inst.setHammer(_client);
        return inst;
    }
}
