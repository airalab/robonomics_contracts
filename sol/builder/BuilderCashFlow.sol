import 'creator/CreatorCashFlow.sol';
import './Builder.sol';

contract BuilderCashFlow {
	function BuilderToken(uint _price, address _cashflow, address _proposal)
             Builder(_price, _cashflow, _proposal)
    {}
	
    function create(address _credits, address _shares) returns (address) {
        var inst = CreatorCashFlow.create(_credits, _shares);
        Owned(inst).delegate(msg.sender);
		
		deal(inst);
        return inst;
    }
}
