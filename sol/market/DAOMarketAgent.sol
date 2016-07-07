import './MarketRegulator.sol';

contract DAOMarketAgent is MarketAgent {
    MarketRegulator public regulator;

    function DAOMarketAgent(address _regulator)
    { regulator = MarketRegulator(_regulator); }

    /**
     * @dev Take a deal by given lot
     * @param _lot target lot address
     * @return `true` when deal is ok
     */
    function deal(Lot _lot) onlyOwner returns (bool) {
        // Transfer buy value for the lot
        if (!_lot.buy().transferFrom(msg.sender, this, _lot.quantity_buy()))
            throw;
        _lot.buy().approve(_lot, _lot.quantity_buy());

        // Try the deal
        if(!_lot.deal()) throw;

        // Transfer when deal is success
        if (!_lot.sale().transfer(msg.sender, _lot.quantity_sale())) throw;

        // Notify the regulator
        regulator.notifyDeal(_lot);

        // Notify the client
        LotDeal(_lot);
        return true;
    }
}
