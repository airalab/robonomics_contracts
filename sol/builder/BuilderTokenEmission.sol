//
// AIRA Builder for TokenEmission contract
//
// Ethereum address:
//  - Testnet: 0x30c92e56e648e80f69f1fcb580d86ae7ca5a2d3a 
//

import 'creator/CreatorTokenEmission.sol';
import './Builder.sol';

contract BuilderTokenEmission is Builder {
    function BuilderTokenEmission(uint _price, address _cashflow, address _proposal)
             Builder(_price, _cashflow, _proposal)
    {}
    
    function create(string _name, string _symbol, uint8 _decimals, uint256 _start_count) returns (address) {
        var inst = CreatorTokenEmission.create(_name, _symbol, _decimals, _start_count);
        inst.transfer(msg.sender, _start_count);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
