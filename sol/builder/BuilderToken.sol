//
// AIRA Builder for Token contract
//
// Ethereum address:
//  - Testnet: 0xf4c7f9be8c32b20c4e9b844bb09f3e0801f18b89
//

import 'creator/CreatorToken.sol';
import './Builder.sol';

contract BuilderToken is Builder {
    function BuilderToken(uint _price, address _cashflow, address _proposal)
             Builder(_price, _cashflow, _proposal)
    {}
    
    function create(string _name, string _symbol, uint8 _decimals, uint256 _count) returns (address) {
        var inst = CreatorToken.create(_name, _symbol, _decimals, _count);
        inst.transfer(msg.sender, _count);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
