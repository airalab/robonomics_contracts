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
     * @param _lot new market lot
     * @notice only seller can append lot to market
     */
    function append(Lot _lot) {
        if (_lot.seller() == msg.sender) {
            lots.append(_lot);
            ++size;
        }
    }
 
    /**
     * @dev Remove lot by address from market lot list
     * @param _lot market lot address
     * @notice only seller can remove lot from market
     */
    function remove(Lot _lot) {
        if (_lot.seller() == msg.sender) {
            lots.remove(_lot);
            --size;
        }
    }
}
