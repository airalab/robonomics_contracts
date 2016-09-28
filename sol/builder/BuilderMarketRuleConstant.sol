//
// AIRA Builder for MarketRuleConstant contract
//
// Ethereum address:
//  - Testnet: 
//

pragma solidity ^0.4.2;
import 'creator/CreatorMarketRuleConstant.sol';
import './Builder.sol';

/**
 * @title BuilderMarketRuleConstant contract
 */
contract BuilderMarketRuleConstant is Builder {
    /**
     * @dev Run script creation contract
     * @param _emission is how amount of tokens should be emissed
     * @return address new contract
     */
    function create(uint _emission) returns (address) {
        var inst = CreatorMarketRuleConstant.create(_emission);
        deal(inst);
        return inst;
    }
}
