//
// AIRA Builder for KObject contract
//
// Ethereum address:
//  - Testnet: 0xd62517baf6e82ea3b73eb7fe26c31d83af5c5886 
//

import 'creator/CreatorKObject.sol';
import './Builder.sol';

contract BuilderKObject is Builder {
    function BuilderKObject(uint _price, address _cashflow, address _proposal)
             Builder(_price, _cashflow, _proposal)
    {}
    
    function create() returns (address) {
        var inst = CreatorKObject.create();
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
