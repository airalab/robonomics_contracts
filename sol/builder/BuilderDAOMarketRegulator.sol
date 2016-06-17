//
// AIRA Builder for DAOMarketRegulator contract
//
// Ethereum address:
//  - Testnet: 0x1f5eb69b7bb72d4ebdcc028983c5188b44a06cc2
//

import 'creator/CreatorDAOMarketRegulator.sol';
import './Builder.sol';

contract BuilderDAOMarketRegulator is Builder {
    function BuilderDAOMarketRegulator(uint _price, address _cashflow, address _proposal)
             Builder(_price, _cashflow, _proposal)
    {}
    
    function create(address _shares, address _thesaurus, address _dao_credits) returns (address) {
        var inst = CreatorDAOMarketRegulator.create(_shares, _thesaurus, _dao_credits);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
