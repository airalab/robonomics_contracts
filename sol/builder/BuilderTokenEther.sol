import 'creator/CreatorTokenEther.sol';
import './Builder.sol';

contract BuilderTokenEther {
	function BuilderToken(uint _price, address _cashflow, address _proposal)
             Builder(_price, _cashflow, _proposal)
    {}
	
    function create(string _name, string _symbol) returns (address) {
        var inst = CreatorTokenEther.create(_name, _symbol);
        Owned(inst).delegate(msg.sender);
		
		deal(inst);
        return inst;
    }
}
