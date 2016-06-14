import 'creator/CreatorKProcess.sol';
import './Builder.sol';

contract BuilderKProcess is Builder {
    function BuilderKProcess(uint _price, address _cashflow, address _proposal)
             Builder(_price, _cashflow, _proposal)
    {}
    
    function create() returns (address) {
        var inst = CreatorKProcess.create();
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
