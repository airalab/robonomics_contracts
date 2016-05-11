import 'lib/AddressArray.sol';
import './Lot.sol';

/**
 * @title Token based market contract
 */
contract Market is Mortal {
    /* Available market lots */
    address[] public lots;
    using AddressArray for address[];

    /**
     * @dev Market size getter
     * @return count of lots
     */
    function size() constant returns (uint)
    { return lots.length; }

    /**
     * @dev Append new lot into market lot list
     * @param _lot new market lot
     */
    function append(Lot _lot)
    { lots.push(_lot); }
 
    /**
     * @dev Remove lot by address from market lot list
     * @param _lot market lot address
     */
    function remove(Lot _lot) {
        if (_lot.seller() == msg.sender) {
            var index = lots.indexOf(_lot);
            lots.remove(index);
        }
    }
}
