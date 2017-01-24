//
// AIRA Builder for CrowdSale start contract
//
// Ethereum address:
//  - Mainnet:
//  - Testnet: 
//

pragma solidity ^0.4.4;
import 'creator/CreatorCrowdSale.sol';
import './Builder.sol';

/**
 * @title BuilderStart contract
 */
contract BuilderCrowdSale is Builder {
    /**
     * @dev Run script creation contract
     * @param _target is a target address for send given credits of success end
     * @param _credits is a DAO fund token
     * @param _sale is a saled token
     * @param _start_time_sec is start time  in seconds
     * @param _duration_sec is a duration in seconds
     * @param _start_price is a start price of shares in credits
     * @param _step is a step of price in percents
     * @param _period_sec is a period of price step in seconds
     * @param _min_value is a minimal received value of credits for success finish
     * @param _end_value is a complete value of credits for success termination
     * @param _client is a contract destination address (zero for sender)
     * @return address new contract
     */
    function create(address _target, address _credits, address _sale,
                    uint _start_time_sec, uint _duration_sec,
                    uint _start_price, uint _step, uint _period_sec,
                    uint _min_value, uint _end_value, address _client) payable returns (address) {
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
 
        var inst = CreatorCrowdSale.create(_target, _credits, _sale,
                                     _start_time_sec, _duration_sec,
                                     _start_price, _step, _period_sec,
                                     _min_value, _end_value);
        getContractsOf[_client].push(inst);
        Builded(_client, inst);
        inst.setOwner(_client);
        inst.setHammer(_client);
        return inst;
    }
}
