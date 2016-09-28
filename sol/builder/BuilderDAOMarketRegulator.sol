//
// AIRA Builder for DAOMarketRegulator contract
//
// Ethereum address:
//  - Testnet: 0x1f5eb69b7bb72d4ebdcc028983c5188b44a06cc2
//

pragma solidity ^0.4.2;
import 'creator/CreatorDAOMarketRegulator.sol';
import './Builder.sol';

/**
 * @title BuilderDAOMarketRegulator contract
 */
contract BuilderDAOMarketRegulator is Builder {
    /**
     * @dev Run script creation contract
     * @param _shares is address shares token
     * @param _core is DAO core address
     * @param _market is DAO market address
     * @param _dao_credits is address credits token
     * @return address new contract
     */
    function create(address _shares, address _core, address _market, address _dao_credits) returns (address) {
        var inst = CreatorDAOMarketRegulator.create(_shares, _core, _market, _dao_credits);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
