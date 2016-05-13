import './MarketRule.sol';

/**
 * @title The constant market rule, return constant emission value for every deal
 */
contract MarketRuleConstant is MarketRule {
    uint public emission;

    function MarketRuleConstant(uint _emission)
    { emission = _emission; }

    /**
     * @dev How amount of token emission needed when given lot is deal
     * @param _deal lot address
     * @return count of emission token value
     */
    function getEmission(Lot _deal) returns (uint)
    { return emission; }
}
