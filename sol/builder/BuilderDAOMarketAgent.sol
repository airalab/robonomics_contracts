import 'creator/CreatorDAOMarketAgent.sol';
import './Builder.sol';

contract BuilderDAOMarketAgent is Builder {
	function BuilderDAOMarketAgent(uint _price, address _cashflow, address _proposal)
             Builder(_price, _cashflow, _proposal)
    {}
	
    function create(address _thesaurus, address _regulator) returns (address) {
        var inst = CreatorDAOMarketAgent.create(_thesaurus, _regulator);
        Owned(inst).delegate(msg.sender);
		
		deal(inst);
        return inst;
    }
}
