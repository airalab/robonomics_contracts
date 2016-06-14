import 'creator/CreatorDAOMarketRegulator.sol';
import './Builder.sol';

contract BuilderDAOMarketRegulator is Builder {
	function BuilderDAOMarketRegulator(uint _price, address _cashflow, address _proposal)
             Builder(_price, _cashflow, _proposal)
    {}
	
    function create(address _shares, address _thesaurus, address _dao_credits) returns (address) {
        var inst = CreatorDAOMarketRegulator.create(_shares, _thesaurus, _dao_credits);
        Owned(inst).delegate(msg.sender);
		
		deal(inst);
        return inst;
    }
}
