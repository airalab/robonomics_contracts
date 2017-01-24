pragma solidity ^0.4.4;
import 'common/Object.sol';
import 'token/Token.sol';

/**
 * @title Token lot for market
 *        presents available deal based on token transfers
 */
contract Lot is Object {
    /* Operational tokens */
    Token public sale;
    Token public buy;

    /* Operational addreses */
    address public seller;
    address public buyer;

    /* Operation description */
    uint public quantity_sale = 0; // Value of sale tokens
    uint public quantity_buy  = 0; // Value of buy tokens

    /* Lot is deal and closed */
    bool public closed = false;

    /**
     * @dev Market lot contruction
     * @param _seller is a seller address
     * @param _sale the token to sale by this lot
     * @param _buy the token to buy by this lot
     * @param _quantity_sale amount of tokens to sale;
     * @param _quantity_buy amount of tokens to buy 
     */
    function Lot(address _seller, address _sale, address _buy,
                 uint _quantity_sale, uint _quantity_buy) {
        seller        = _seller;
        sale          = Token(_sale);
        buy           = Token(_buy);
        quantity_sale = _quantity_sale;
        quantity_buy  = _quantity_buy;
    }

    /**
     * @dev this event emitted when lot close
     */
    event Closed(uint indexed time);
 
    /**
     * @dev Lot deal method with buyer in argument
     * @param _buyer address of buyer
     * @return `true` when deal is success
     */
    function deal(address _buyer) returns (bool) {
        // So if lot is closed no deal available
        if (closed) return false;

        // Do transfer tokens
        if (!sale.transferFrom(seller, _buyer, quantity_sale)
         || !buy.transferFrom(_buyer, seller, quantity_buy)) throw;

        // Store buyer and close lot
        buyer = _buyer;
        closed = true;
        
        // Notify all for deal done
        Closed(now);
        return true;
    }
 
    /**
     * @dev Lot deal with buyer is a `sender`, see deal(address)
     */
    function deal() returns (bool)
    { return deal(msg.sender); }
}
