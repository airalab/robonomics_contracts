//
// AIRA Builder for KnowledgeStorage contract
//
// Ethereum address:
//  - Testnet: 0x6e1b20543d14e7059608ce8fc0bcd841d006c157
//

import 'creator/CreatorKnowledgeStorage.sol';
import './Builder.sol';

/**
 * @title BuilderKnowledgeStorage contract
 */
contract BuilderKnowledgeStorage is Builder {
    function BuilderKnowledgeStorage(uint _buildingCost, address _cashflow, address _proposal)
             Builder(_buildingCost, _cashflow, _proposal)
    {}
    
    /**
     * @dev Run script creation contract
     * @return address new contract
     */
    function create() returns (address) {
        var inst = CreatorKnowledgeStorage.create();
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
