//
// AIRA Builder for TokenSpec contract
//
// Ethereum address:
//  - Testnet: 0x279424b9fe32f3dcfb8c2bde51397ba099379ec2
//

import 'creator/CreatorTokenSpec.sol';
import './Builder.sol';

/**
 * @title BuilderTokenSpec contract
 */
contract BuilderTokenSpec is Builder {
    function BuilderTokenSpec(uint _buildingCost, address _cashflow, address _proposal)
             Builder(_buildingCost, _cashflow, _proposal)
    {}
    
    /**
     * @dev Run script creation contract
     * @param _name is name token
     * @param _symbol is symbol token
     * @param _decimals is fixed point position
     * @param _count is count of tokens exist
     * @param _spec is specification
     * @return address new contract
     */
    function create(string _name, string _symbol, uint8 _decimals, uint256 _count, address _spec) returns (address) {
        var inst = CreatorTokenSpec.create(_name, _symbol, _decimals, _count, _spec);
        inst.transfer(msg.sender, _count);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
