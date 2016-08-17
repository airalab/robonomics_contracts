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
    /**
     * @dev Run script creation contract
     * @param _target is a target of funds
     * @param _etherFund is a ether wallet token
     * @param _shares is a shareholders token contract 
     * @param _price_wei is price of one share in wei
     * @return address new contract
     */
    function create(address _target, address _etherFund,
                    address _shares, uint _price_wei) returns (address) {
        var inst = CreatorShareSale.create(_target, _etherFund, _shares, _price_wei);
        Owned(inst).delegate(msg.sender);
        
        deal(inst);
        return inst;
    }
}
