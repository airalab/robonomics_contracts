import 'lib/AddressList.sol';
import './Lot.sol';

/**
 * @title Token based market contract
 */
contract Market is Mortal {
    /* Available market lots */
    AddressList.Data lots;
    using AddressList for AddressList.Data;

    /* Market size */
    uint public size = 0;

    bool public open = true;

    /**
     * @dev Market mode modifier, the open mode by defaul allow anyone place lot on market
     *      in another case(`false` in open var) only owner can place a lot, this sute is 
     *      used e.g. regulator
     * @param _open is new mode value
     */
    function setMode(bool _open) onlyOwner
    { open = _open; }

    /**
     * @dev Take a first lot from market
     * @return first lot
     */
    function first() constant returns (Lot)
    { return Lot(lots.first()); }

    /**
     * @dev Take next lot from market
     * @param _current is a current lot
     * @return next lot
     */
    function next(Lot _current) constant returns (Lot)
    { return Lot(lots.next(_current)); }

    /**
     * @dev Check for lot placed on market
     * @param _lot is a lot
     * @return `true` when lot already placed on
     */
    function contains(Lot _lot) constant returns (bool)
    { return lots.contains(_lot); }

    /**
     * @dev Append new lot into market lot list
     * @param _seller is a seller address
     * @param _sale the token to sale by this lot
     * @param _buy the token to buy by this lot
     * @param _value amount of saled tokens
     * @param _price how many `_buy` tokens will send for one `_sale`
     * @return new lot address
     */
    function append(address _seller, address _sale, address _buy,
                    uint _value, uint _price) returns (Lot) {
        if (!open && msg.sender != owner) throw;

        var lot = new Lot(_seller, _sale, _buy, _value, _price);
        lots.append(lot);
        ++size;
        return lot;
    }
 
    /**
     * @dev Remove lot by address from market lot list
     * @param _lot market lot address
     * @notice only seller can remove lot from market
     */
    function remove(Lot _lot) {
        if (_lot.seller() == msg.sender || _lot.closed()) {
            lots.remove(_lot);
            --size;
        }
    }
}
