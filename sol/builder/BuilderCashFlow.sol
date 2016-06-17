//
// AIRA Builder for CashFlow contract
//
// Ethereum address:
//  - Testnet: 0x7d587d24ca05a7384b245d260bca3f6deda56a86
//

import 'creator/CreatorCashFlow.sol';
import './Builder.sol';

/**
 * @title BuilderCashFlow contract
 */
contract BuilderCashFlow is Builder {
    function BuilderCashFlow(uint _buildingCost, address _cashflow, address _proposal)
             Builder(_buildingCost, _cashflow, _proposal)
    {}
    
    /**
     * @dev Run script creation contract
     * @param _credits is address credits token
     * @param _shares is address shares token
     * @return address new contract
     */
    function create(address _credits, address _shares) returns (address) {
        var inst = CreatorCashFlow.create(_credits, _shares);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
