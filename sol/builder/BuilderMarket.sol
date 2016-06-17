//
// AIRA Builder for Market contract
//
// Ethereum address:
//  - Testnet: 0x63ef4b59c672620c4f84b8d432385727a8c95252
//

import 'creator/CreatorMarket.sol';
import './Builder.sol';

/**
 * @title BuilderMarket contract
 */
contract BuilderMarket is Builder {
    function BuilderMarket(uint _buildingCost, address _cashflow, address _proposal)
             Builder(_buildingCost, _cashflow, _proposal)
    {}
    
    /**
     * @dev Run script creation contract
     * @return address new contract
     */
    function create() returns (address) {
        var inst = CreatorMarket.create();
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
