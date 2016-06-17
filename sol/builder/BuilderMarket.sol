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
