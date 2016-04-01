import 'token.sol';

/*
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

    function Lot(Token _sale, Token _buy, uint _value, uint _price) {
        sale   = _sale;
        buy    = _buy;
        value  = _value;
        price  = _price;
        seller = msg.sender;
    }
    
    /* Lot deal with buyer is a sender */
    function deal() returns (bool) {
        return deal(msg.sender);
    }

    /* Lot deal method with buyer in argument */
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
}

/*
 * Token based market contract
 */
contract Market is Mortal {
    /* Market configuration */
    struct Config {
        /* Market name */
        string name;
        /* Available market lots */
        Array.Data lots;
    }

    Config market;

    /* Common used array iterator */
    Array.Iterator it;

    /* Public getters */
    function getName() returns (string)
    { return market.name; }

    function getLotLength() returns (uint)
    { return Array.size(market.lots); }

    function getLot(uint _index) returns (Lot)
    { return Lot(Array.get(market.lots, _index)); }

    /* Market constructor */
    function Market(string _name) {
        market.name = _name;
    }

    /*
     * The lot on market manipulations
     */
    function placeLot(Lot _lot)
    { Array.append(market.lots, _lot); }
 
    function removeLot(Lot _lot) {
        if (_lot.seller() == msg.sender) {
            Array.setBegin(market.lots, it);
            Array.find(it, _lot);
            Array.remove(it);
        }
    }
    
    /*
     * Client public methods
     */
    function bestDeal(Token _buy, uint _value) returns (Lot) {
        Lot best = Lot(0);
        
        Array.setBegin(market.lots, it);
        while (!Array.end(it)) {
            var lot = Lot(Array.get(it));
            /* Drop closed lots from array */
            if (lot.closed()) {
                Array.remove(it);
                continue;
            }
            /* So the lot is candidate to best if token and value suit */
            if (lot.sale() == _buy && lot.value() >= _value)
                /* Best price - low price */
                if (best == Lot(0) || best.price() > lot.price())
                    best = lot;
            /* Step next */
            Array.next(it);
        }
        return best;
    }
}
