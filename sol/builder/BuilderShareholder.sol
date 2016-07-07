//
// AIRA Builder for Shareholder contract
//
// Ethereum address:
//  - Testnet: 
//

import 'creator/CreatorShareholder.sol';
import './Builder.sol';

/**
 * @title BuilderShareholder contract
 */
contract BuilderShareholder is Builder {
    function BuilderShareholder(uint _buildingCost, address _cashflow, address _proposal)
             Builder(_buildingCost, _cashflow, _proposal)
    {}
    
    /**
     * @dev Run script creation contract
     * @param _shares is a shares token address
     * @param _count is a count of shares for transfer
     * @param _recipient is a shares recipient
     * @return address new contract
     */
    function create(address _shares, uint _count, address _recipient) returns (address) {
        var inst = CreatorShareholder.create(_shares, _count, _recipient);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
