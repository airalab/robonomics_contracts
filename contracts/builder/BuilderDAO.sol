//
// AIRA Builder for basic DAO contracts
//
// Ethereum address:
//  - Mainnet:
//  - Testnet: 
//

pragma solidity ^0.4.4;
import 'creator/CreatorTokenEmission.sol';
import 'creator/CreatorCore.sol';
import './Builder.sol';

contract BuilderDAO is Builder {
    function create(string _dao_name, string _dao_description,
                    string _shares_name, string _shares_symbol,
                    uint _shares_count, address _client) payable returns (address) {
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
 
        var shares = CreatorTokenEmission.create(_shares_name, _shares_symbol, 0, _shares_count);
        shares.transfer(_client, _shares_count);
        shares.setOwner(_client);
        shares.setHammer(_client);

        var dao = CreatorCore.create(_dao_name, _dao_description);
        // Append shares module
        dao.set(_shares_name, shares,
                "github://airalab/core/token/TokenEmission.sol", true);

        // Delegate DAO to sender
        getContractsOf[_client].push(dao);
        Builded(_client, dao);
        dao.setOwner(_client);
        dao.setHammer(_client);
        return dao;
    }
}
