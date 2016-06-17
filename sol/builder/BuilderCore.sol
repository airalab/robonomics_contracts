//
// AIRA Builder for Core contract
//
// Ethereum address:
//  - Testnet: 0x65db698e7a340bc73a60a7da2762feb33b0a312f
//

import 'creator/CreatorCore.sol';
import './Builder.sol';

contract BuilderCore is Builder {
    function BuilderCore(uint _price, address _cashflow, address _proposal)
             Builder(_price, _cashflow, _proposal)
    {}
    
    function create(string _name, string _description) returns (address) {
        var inst = CreatorCore.create(_name, _description);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
