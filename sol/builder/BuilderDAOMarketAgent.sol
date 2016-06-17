//
// AIRA Builder for DAOMarketAgent contract
//
// Ethereum address:
//  - Testnet: 0x5aa1e4b0c20b31d0cb78b603b4bd91935ec8a033
//

import 'creator/CreatorDAOMarketAgent.sol';
import './Builder.sol';

contract BuilderDAOMarketAgent is Builder {
    function BuilderDAOMarketAgent(uint _price, address _cashflow, address _proposal)
             Builder(_price, _cashflow, _proposal)
    {}
    
    function create(address _thesaurus, address _regulator) returns (address) {
        var inst = CreatorDAOMarketAgent.create(_thesaurus, _regulator);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
