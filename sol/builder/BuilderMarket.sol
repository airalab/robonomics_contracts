import 'creator/CreatorMarket.sol';
import './Builder.sol';

contract BuilderMarket is Builder {
    function BuilderMarket(uint _price, address _cashflow, address _proposal)
             Builder(_price, _cashflow, _proposal)
    {}
    
    function create() returns (address) {
        var inst = CreatorMarket.create();
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
