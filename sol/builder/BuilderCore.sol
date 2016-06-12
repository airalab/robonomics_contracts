import 'creator/CreatorCore.sol';
import './Builder.sol';

contract BuilderCore {
	function BuilderToken(uint _price, address _cashflow, address _proposal)
             Builder(_price, _cashflow, _proposal)
    {}
	
    function create(string _name, string _description) returns (address) {
        var inst = CreatorCore.create(_name, _description);
        Owned(inst).delegate(msg.sender);
		
		deal(inst);
        return inst;
    }
}
