import 'creator/CreatorDAOKnowledgeStorage.sol';
import './Builder.sol';

/**
 * @title BuilderDAOKnowledgeStorage contract
 */
contract BuilderDAOKnowledgeStorage is Builder {
    function BuilderDAOKnowledgeStorage(uint _buildingCost, address _cashflow, address _proposal)
             Builder(_buildingCost, _cashflow, _proposal)
    {}
    
    /**
     * @dev Run script creation contract
     * @param _thesaurus is address thesaurus
     * @param _shares is address shares token
     * @return address new contract
     */
    function create(address _thesaurus, address _shares) returns (address) {
        var inst = CreatorDAOKnowledgeStorage.create(_thesaurus, _shares);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
