//
// AIRA Builder for IPO start contract
//
// Ethereum address:
//

import 'creator/CreatorCashFlow.sol';
import 'creator/CreatorIPO.sol';
import './Builder.sol';

/**
 * @title BuilderIPOStart contract
 */
contract BuilderIPOStart is Builder {
    function BuilderIPOStart(uint _buildingCost, address _cashflow, address _proposal)
             Builder(_buildingCost, _cashflow, _proposal)
    {}
    
    /**
     * @dev Run script creation contract
     * @param _credits is a credits token
     * @param _shares is a shares token
     * @param _start_time_sec is start time of IPO in seconds
     * @param _duration_sec is a duration of IPO in seconds
     * @param _start_price is a start price of shares in credits
     * @param _step is a step of price in percents
     * @param _period_sec is a period of price step in seconds
     * @param _min_value is a minimal received value of credits for success finish
     * @param _end_value is a complete value of credits for success termination
     * @return address new contract
     */
    function create(address _credits, address _shares,
                    uint _start_time_sec, uint _duration_sec,
                    uint _start_price, uint _step, uint _period_sec,
                    uint _min_value, uint _end_value) returns (address) {
        var cashflow = CreatorCashFlow.create(_credits, _shares);
        Owned(cashflow).delegate(msg.sender);

        var inst = CreatorIPO.create(cashflow, _start_time_sec, _duration_sec,
                                     _start_price, _step, _period_sec,
                                     _min_value, _end_value);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
