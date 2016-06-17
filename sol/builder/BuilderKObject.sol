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
