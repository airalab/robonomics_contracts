//
// AIRA Builder for Token contract
//
// Ethereum address:
//  - Testnet: 0xf4c7f9be8c32b20c4e9b844bb09f3e0801f18b89
//

import 'creator/CreatorToken.sol';
import './Builder.sol';

/**
 * @title BuilderToken contract
 */
contract BuilderToken is Builder {
    function BuilderToken(uint _buildingCost, address _cashflow, address _proposal)
             Builder(_buildingCost, _cashflow, _proposal)
    {}
    
    /**
     * @dev Run script creation contract
     * @param _name is name token
     * @param _symbol is symbol token
     * @param _decimals is fixed point position
     * @param _count is count of tokens exist
     * @return address new contract
     */
    function create(string _name, string _symbol, uint8 _decimals, uint256 _count) returns (address) {
        var inst = CreatorToken.create(_name, _symbol, _decimals, _count);
        inst.transfer(msg.sender, _count);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
