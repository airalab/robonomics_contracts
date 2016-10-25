//
// AIRA Builder for Token contract
//
// Ethereum address:
//  - Mainnet:
//  - Testnet: 
//

pragma solidity ^0.4.2;
import 'creator/CreatorToken.sol';
import './Builder.sol';

/**
 * @title BuilderToken contract
 */
contract BuilderToken is Builder {
    /**
     * @dev Run script creation contract
     * @param _name is name token
     * @param _symbol is symbol token
     * @param _decimals is fixed point position
     * @param _count is count of tokens exist
     * @return address new contract
     */
    function create(string _name, string _symbol, uint8 _decimals, uint256 _count) returns (address) {
        if (buildingCostWei > 0 && beneficiary != 0) {
            // Too low value
            if (msg.value < buildingCostWei) throw;
            // Beneficiary send
            if (!beneficiary.send(buildingCostWei)) throw;
            // Refund
            if (!msg.sender.send(msg.value - buildingCostWei)) throw;
        } else {
            // Refund all
            if (msg.value > 0) {
                if (!msg.sender.send(msg.value)) throw;
            }
        }
 
        var inst = CreatorToken.create(_name, _symbol, _decimals, _count);
        getContractsOf[msg.sender].push(inst);
        Builded(msg.sender, inst);
        inst.transfer(msg.sender, _count);
        inst.delegate(msg.sender);
        return inst;
    }
}
