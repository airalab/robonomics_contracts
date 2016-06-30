//
// AIRA Builder for ShareSale contract
//
// Ethereum address:
//  - Testnet: 0x56c58efbf174dc82b4311a68b84bdfd5db13a3db 
//

import 'creator/CreatorShareSale.sol';
import './Builder.sol';

/**
 * @title ShareSale contract builder
 */
contract BuilderShareSale is Builder {
    function BuilderShareSale(uint _buildingCost, address _cashflow, address _proposal)
             Builder(_buildingCost, _cashflow, _proposal)
    {}
    
    /**
     * @dev Run script creation contract
     * @param _cashflow is Cashflow address
     * @param _price_wei is price of one share in wei
     * @return address new contract
     */
    function create(address _cashflow, uint _price_wei) returns (address) {
        var inst = CreatorShareSale.create(_cashflow, _price_wei);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
