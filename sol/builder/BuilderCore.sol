import 'creator/CreatorCore.sol';
import './Builder.sol';

/**
 * @title BuilderCore contract
 */
contract BuilderCore is Builder {
    function BuilderCore(uint _buildingCost, address _cashflow, address _proposal)
             Builder(_buildingCost, _cashflow, _proposal)
    {}
    
    /**
     * @dev Run script creation contract
     * @param _name is DAO name
     * @param _description is DAO description
     * @return address new contract
     */
    function create(string _name, string _description) returns (address) {
        var inst = CreatorCore.create(_name, _description);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
