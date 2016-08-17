//
// AIRA Builder for TokenEmissionACL contract
//
// Ethereum address:
//  - Testnet: 
//

import 'creator/CreatorTokenEmissionACL.sol';
import './Builder.sol';

/**
 * @title BuilderTokenEmissionACL contract
 */
contract BuilderTokenEmissionACL is Builder {
    /**
     * @dev Run script creation contract
     * @param _name is name token
     * @param _symbol is symbol token
     * @param _decimals is fixed point position
     * @param _start_count is count of tokens exist
     * @param _acl_storage is an ACL storage contract
     * @param _emitent is a emitent group name
     * @return address new contract
     */
    function create(string _name, string _symbol,
                    uint8 _decimals, uint256 _start_count,
                    address _acl_storage, string _emitent) returns (address) {
        var inst = CreatorTokenEmissionACL.create(_name, _symbol, _decimals,
                                                  _start_count, _acl_storage, _emitent);
        inst.transfer(msg.sender, _start_count);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
