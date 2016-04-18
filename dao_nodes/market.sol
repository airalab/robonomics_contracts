import 'token.sol';

/**
 * Token lot for market
 *   presents available deal based on token transfers
 */
contract Lot is Mortal {
    /* Operational tokens */
    Token public sale;
    Token public buy;

    /* Operational addreses */
    address public seller;
    address public buyer;

    /* Operation description */
    uint public value = 0; // Value of sale tokens
    uint public price = 0; // Price one sale token in buy tokens

    /* Lot is deal and closed */
    bool public closed = false;

    /**
     * Market lot contruction
     * @param _sale the token to sale by this lot
     * @param _buy the token to buy by this lot
     * @param _value amount of saled tokens
     * @param _price how many `_buy` tokens will send for one `_sale`
     */
    function Lot(Token _sale, Token _buy, uint _value, uint _price) {
        sale   = _sale;
        buy    = _buy;
        value  = _value;
        price  = _price;
        seller = msg.sender;
    }
    
    /**
     * Lot deal method with buyer in argument
     * @param _buyer address of buyer
     */
    function deal(address _buyer) returns (bool) {
        /* So if lot is closed no deal available */
        if (closed) return false;

        /* Check it to deal this lot */
        if (sale.getBalance(seller) >= value
          && buy.getBalance(_buyer) >= value * price) {

            // Do transfer tokens
            sale.transferFrom(seller, _buyer, value);
            buy.transferFrom(_buyer, seller, value * price);

            // Store buyer and close lot
            buyer = _buyer;
            closed = true;
            return true;
        }
        return false;
    }
 
    /**
     * Lot deal with buyer is a `sender`
     * @see deal(_buyer)
     */
    function deal() returns (bool)
    { return deal(msg.sender); }
}

/**
 * Token based market contract
 */
contract Market is Mortal {
    /* Market name */
    string public name;
    
    /* Available market lots */
    address[] public lots;
    using AddressArray for address[];

    /* Market constructor */
    function Market(string _name)
    { name = _name; }

    /*
     * The lot on market manipulations
     */

    /**
     * Append new lot into market lot list
     * @param _lot new market lot
     */
    function appendLot(Lot _lot)
    { lots.push(_lot); }
 
    /**
     * Remove lot by address from market lot list
     * @param _lot market lot address
     */
    function removeLot(Lot _lot) {
        if (_lot.seller() == msg.sender) {
            var index = lots.indexOf(_lot);
            lots.remove(index);
        }
    }

    /*
     * Client public methods
     */
    /**
     * Take a best lot for given sale and buy tokens with minimal value
     * The best lot is a cheapest lot
     * @param _buy the token to buy
     * @param _sell the token to sell
     * @param _value amount of tokens to buy
     * @return market lot address or zero if not found
     */
    function bestDeal(Token _buy, Token _sell, uint _value) constant returns (Lot) {
        Lot best = Lot(0);

        /* Step over all lots */
        for (uint i = 0; i < lots.length; i += 1) {
            var lot = Lot(lots[i]);
            /* Drop closed lots from array */
            if (lot.closed()) {
                lots.remove(i);
                continue;
            }
            /* So the lot is candidate to best if token and value suit */
            if (lot.sale() == _buy && lot.buy() == _sell && lot.value() >= _value)
                /* Best price - low price */
                if (best == Lot(0) || best.price() > lot.price())
                    best = lot;
        }
        return best;
    }
}

/**
 * Very usefull abstract contract
 * presents autonomous agent that use the market and self created tokens
 */
contract MarketAgent {
    /* The current agent token */
    Token  public getToken;
    /* The public token used by agent */
    Token  public getPublicToken;
    /* The market that used by agent */
    Market public getMarket;

    /**
     * Market agent is a contract that have a associated market,
     * self token and public token for market trading
     * @param _publicToken token used by market trading (e.g. DAO token)
     * @param _market market address for trading (e.g. DAO market)
     */
    function MarketAgent(Token _publicToken, Market _market) {
        getPublicToken = _publicToken;
        getMarket      = _market;
        /* Making the internal token */
        makeToken();
    }

    function makeToken() internal;

    /**
     * Place a Lot on market with price in public tokens
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
