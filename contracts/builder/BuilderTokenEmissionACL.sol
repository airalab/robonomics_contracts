//
// AIRA Builder for TokenEmissionACL contract
//
// Ethereum address:
//  - Mainnet:
//  - Testnet: 
//

pragma solidity ^0.4.4;
import 'creator/CreatorTokenEmissionACL.sol';
import './Builder.sol';

/**
 * @title BuilderTokenEmissionACL contract
 */
contract BuilderTokenEmissionACL is Builder {
    /**
     * @dev Run script creation contract
     * @param _name is name token
     * @param _symbol is symbol token
     * @param _decimals is fixed point position
     * @param _start_count is count of tokens exist
     * @param _acl_storage is an ACL storage contract
     * @param _emitent is a emitent group name
     * @param _client is a contract destination address (zero for sender)
     * @return address new contract
     */
    function create(string _name, string _symbol,
                    uint8 _decimals, uint256 _start_count,
                    address _acl_storage, string _emitent, address _client) payable returns (address) {
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
 
        var inst = CreatorTokenEmissionACL.create(_name, _symbol, _decimals,
                                                  _start_count, _acl_storage, _emitent);
        getContractsOf[_client].push(inst);
        Builded(_client, inst);
        inst.transfer(_client, _start_count);
        inst.setOwner(_client);
        inst.setHammer(_client);
        return inst;
    }
}
