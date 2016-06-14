import 'creator/CreatorTokenSpec.sol';
import './Builder.sol';

contract BuilderTokenSpec is Builder {
    function BuilderTokenSpec(uint _price, address _cashflow, address _proposal)
             Builder(_price, _cashflow, _proposal)
    {}
    
    function create(string _name, string _symbol, uint8 _decimals, uint256 _count, address _spec) returns (address) {
        var inst = CreatorTokenSpec.create(_name, _symbol, _decimals, _count, _spec);
        inst.transfer(msg.sender, _count);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
