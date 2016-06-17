//
// AIRA Builder for KProcess contract
//
// Ethereum address:
//  - Testnet: 0x5dbb929292c3409bddaa6d5fd9744ef3f214a51c 
//

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
