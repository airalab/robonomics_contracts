import 'common/Mortal.sol';
import 'token/Token.sol';

/**
 * @title Token lot for market
 *        presents available deal based on token transfers
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
     * @dev Market lot contruction
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
     * @dev this event emitted when lot close
     */
    event DealDone();
    
    /**
     * @dev Lot deal method with buyer in argument
     * @param _buyer address of buyer
     * @return `true` when deal is success
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

            // Notify all for deal done
            DealDone();
            return true;
        }
        return false;
    }
 
    /**
     * @dev Lot deal with buyer is a `sender`, see deal(address)
     */
    function deal() returns (bool)
    { return deal(msg.sender); }
}
