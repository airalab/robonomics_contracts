import 'creator/CreatorKProcess.sol';
import './Builder.sol';

/**
 * @title BuilderKProcess contract
 */
contract BuilderKProcess is Builder {
    function BuilderKProcess(uint _buildingCost, address _cashflow, address _proposal)
             Builder(_buildingCost, _cashflow, _proposal)
    {}
    
    /**
     * @dev Run script creation contract
     * @return address new contract
     */
    function create() returns (address) {
        var inst = CreatorKProcess.create();
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
