import 'thesaurus/KnowledgeStorage.sol';
import 'market/MarketRegulator.sol';

contract DAOMarketAgent is MarketAgent {
    MarketRegulator   regulator;
    KnowledgeStorage  thesaurus; 

    function DAOMarketAgent(address _thesaurus, address _regulator) {
        regulator = MarketRegulator(_regulator);
        thesaurus = KnowledgeStorage(_thesaurus);
    }

    /**
     * @dev Place lot on the market
     * @param _name traded item term name
     * @param _token traded token
     * @param _value how much items traded
     * @param _price one item price
     * @return placed lot address for tracking
     */
    function put(string _name, TokenSpec _token,
                 uint _value,  uint _price) onlyOwner returns (Lot) {
        // Check knowledge consistence
        var spec = thesaurus.get(_name);
        if (!spec.isEqual(_token.specification()))
            throw;

        // Transfer traded token to self
        if (!_token.transferFrom(msg.sender, this, _value))
            throw;

        // Approve credits that will be given from deal
        regulator.credits().approve(msg.sender, _value * _price);

        // Make lot and place on market
        var lot = new Lot(_token, regulator.credits(), _value, _price);
        regulator.market().append(lot);

        // Approve lot in traded token for deal
        _token.approve(lot, _value);

        // Notify the client
        LotPlaced(lot);
        return lot;
    }

    /**
     * @dev Take a deal by given lot
     * @param _lot target lot address
     * @return `true` when deal is ok
     */
    function deal(Lot _lot) onlyOwner returns (bool) {
        var buyValue = _lot.value() * _lot.price();
        // Check balance of sender for the deal

        // Transfer buy value for the lot
        if (!_lot.buy().transferFrom(msg.sender, this, buyValue))
            return false;
        _lot.buy().approve(_lot, buyValue);

        // Try the deal
        if(!_lot.deal()) {
            // Refund when deal isn't ok
            _lot.buy().transfer(msg.sender, buyValue); 
            return false;
        }

        // Transfer when deal is success
        _lot.sale().transfer(msg.sender, _lot.value());

        // Notify the regulator
        regulator.dealDone(_lot);

        // Notify the client
        LotDeal(_lot);
        return true;
    }
}
