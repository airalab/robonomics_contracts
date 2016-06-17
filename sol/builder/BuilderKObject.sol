//
// AIRA Builder for KObject contract
//
// Ethereum address:
//  - Testnet: 0xd62517baf6e82ea3b73eb7fe26c31d83af5c5886 
//

import 'creator/CreatorKObject.sol';
import './Builder.sol';

/**
 * @title BuilderKObject contract
 */
contract BuilderKObject is Builder {
    function BuilderKObject(uint _buildingCost, address _cashflow, address _proposal)
             Builder(_buildingCost, _cashflow, _proposal)
    {}
    
    /**
     * @dev Run script creation contract
     * @return address new contract
     */
    function create() returns (address) {
        var inst = CreatorKObject.create();
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
