//
// AIRA Builder for TokenEmission contract
//
// Ethereum address:
//  - Testnet: 0x30c92e56e648e80f69f1fcb580d86ae7ca5a2d3a 
//

import 'creator/CreatorTokenEmission.sol';
import './Builder.sol';

/**
 * @title BuilderTokenEmission contract
 */
contract BuilderTokenEmission is Builder {
    function BuilderTokenEmission(uint _buildingCost, address _cashflow, address _proposal)
             Builder(_buildingCost, _cashflow, _proposal)
    {}
    
    /**
     * @dev Run script creation contract
     * @param _name is name token
     * @param _symbol is symbol token
     * @param _decimals is fixed point position
     * @param _start_count is count of tokens exist
     * @return address new contract
     */
    function create(string _name, string _symbol, uint8 _decimals, uint256 _start_count) returns (address) {
        var inst = CreatorTokenEmission.create(_name, _symbol, _decimals, _start_count);
        inst.transfer(msg.sender, _start_count);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
