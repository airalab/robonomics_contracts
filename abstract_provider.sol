import 'market.sol'

/**
 * @title Very usefull abstract contract
 *        presents autonomous agent that use the market and self created tokens
 */
contract AbstractProvider {
    /* The agent maked token */
    Token  public getProvidedToken;
    /* The public token used by agent */
    Token  public getPublicToken;
    /* The market that used by agent */
    Market public getMarket;

    /**
     * @dev Provider is a contract that have a associated market,
     *      self created token and public token for market trading
     * @param _publicToken token used by market trading (e.g. DAO token)
     * @param _market market address for trading (e.g. DAO market)
     */
    function AbstractTrader(Token _publicToken, Market _market) {
        getPublicToken = _publicToken;
        getMarket      = _market;
        /* Making the internal token */
        makeToken();
    }

    function makeToken() internal;

    /**
     * @dev Place a Lot on market with price in public tokens
     * @param _value amount of tokens to sell
     * @param _price how many public tokens need for one saled
     */
    function placeLot(uint _value, uint _price) internal {
        /* Make lot with given value and price */
        var lot = new Lot(getToken, getPublicToken, _value, _price);
        /* Approve lot to sell */
        getToken.approve(lot, _value);
        /* Register lot on the market */
        getMarket.appendLot(lot);
    }
}
