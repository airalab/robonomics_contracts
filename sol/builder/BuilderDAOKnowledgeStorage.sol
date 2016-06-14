import 'creator/CreatorDAOKnowledgeStorage.sol';
import './Builder.sol';

contract BuilderDAOKnowledgeStorage is Builder {
    function BuilderDAOKnowledgeStorage(uint _price, address _cashflow, address _proposal)
             Builder(_price, _cashflow, _proposal)
    {}
    
    function create(address _thesaurus, address _shares) returns (address) {
        var inst = CreatorDAOKnowledgeStorage.create(_thesaurus, _shares);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
