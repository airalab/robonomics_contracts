import 'creator/CreatorDAOMarketAgent.sol';
import './Builder.sol';

/**
 * @title BuilderDAOMarketAgent contract
 */
contract BuilderDAOMarketAgent is Builder {
    function BuilderDAOMarketAgent(uint _buildingCost, address _cashflow, address _proposal)
             Builder(_buildingCost, _cashflow, _proposal)
    {}
    
    /**
     * @dev Run script creation contract
     * @param _thesaurus is address thesaurus
     * @param _regulator is address regulator
     * @return address new contract
     */
    function create(address _thesaurus, address _regulator) returns (address) {
        var inst = CreatorDAOMarketAgent.create(_thesaurus, _regulator);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
