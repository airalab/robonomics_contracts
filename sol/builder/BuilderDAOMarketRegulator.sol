//
// AIRA Builder for DAOMarketRegulator contract
//
// Ethereum address:
//  - Testnet: 0x1f5eb69b7bb72d4ebdcc028983c5188b44a06cc2
//

import 'creator/CreatorDAOMarketRegulator.sol';
import './Builder.sol';

/**
 * @title BuilderDAOMarketRegulator contract
 */
contract BuilderDAOMarketRegulator is Builder {
    function BuilderDAOMarketRegulator(uint _buildingCost, address _cashflow, address _proposal)
             Builder(_buildingCost, _cashflow, _proposal)
    {}
    
    /**
     * @dev Run script creation contract
     * @param _shares is address shares token
     * @param _thesaurus is address thesaurus
     * @param _dao_credits is address credits token
     * @return address new contract
     */
    function create(address _shares, address _thesaurus, address _dao_credits) returns (address) {
        var inst = CreatorDAOMarketRegulator.create(_shares, _thesaurus, _dao_credits);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
