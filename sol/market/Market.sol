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

    bool public regulatorEnabled = false;

    /**
     * @dev Market mode modifier, the regulator disabled by defaul allow anyone place lot on market
     *      in another case only owner can place a lot, this sute is used for market regulator
     * @param _enable is new regulator mode value
     */
    function setRegulator(bool _enable) onlyOwner
    { regulatorEnabled = _enable; }

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
        if (regulatorEnabled && msg.sender != owner) throw;

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
