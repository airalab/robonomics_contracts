//
// AIRA Builder for BoardOfDirectors contract
//
// Ethereum address:
//  - Testnet: 
//

import 'creator/CreatorBoardOfDirectors.sol';
import './Builder.sol';

/**
 * @title BuilderBoardOfDirectors contract
 */
contract BuilderBoardOfDirectors is Builder {
    /**
     * @dev Run script creation contract
     * @param _dao_core is a DAO core register
     * @param _shares is a share holders token
     * @param _credits is a fund token
     * @return address new contract
     */
    function create(address _dao_core, address _shares, address _credits) returns (address) {
        var inst = CreatorBoardOfDirectors.create(_dao_core, _shares, _credits);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
