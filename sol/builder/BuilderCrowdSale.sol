//
// AIRA Builder for CrowdSale start contract
//
// Ethereum address:
//

import 'creator/CreatorCrowdSale.sol';
import './Builder.sol';

/**
 * @title BuilderStart contract
 */
contract BuilderCrowdSale is Builder {
    function BuilderCrowdSale(uint _buildingCost, address _cashflow, address _proposal)
             Builder(_buildingCost, _cashflow, _proposal)
    {}
    
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
     * @return address new contract
     */
    function create(address _target, address _credits, address _sale,
                    uint _start_time_sec, uint _duration_sec,
                    uint _start_price, uint _step, uint _period_sec,
                    uint _min_value, uint _end_value) returns (address) {
        var inst = CreatorCrowdSale.create(_target, _credits, _sale,
                                     _start_time_sec, _duration_sec,
                                     _start_price, _step, _period_sec,
                                     _min_value, _end_value);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
