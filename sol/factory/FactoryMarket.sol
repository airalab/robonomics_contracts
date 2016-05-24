import 'market/Market.sol';

library FactoryMarket {
    function create() returns (Market)
    { return new Market(); }
}
