import 'creator/CreatorKnowledgeStorage.sol';
import './Builder.sol';

contract BuilderKnowledgeStorage is Builder {
	function BuilderKnowledgeStorage(uint _price, address _cashflow, address _proposal)
             Builder(_price, _cashflow, _proposal)
    {}
	
    function create() returns (address) {
        var inst = CreatorKnowledgeStorage.create();
        Owned(inst).delegate(msg.sender);
		
		deal(inst);
        return inst;
    }
}
