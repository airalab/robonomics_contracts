import './Lot.sol';

/**
 * @title The market rule interface 
 */
contract MarketRule {
    /**
     * @dev How amount of token emission needed when given lot is deal
     * @param _deal lot address
     * @return count of emission token value
     */
    function getEmission(Lot _deal) returns (uint);
}
