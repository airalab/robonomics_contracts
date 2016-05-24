import 'thesaurus/Knowledge.sol';
import 'token/TokenSpec.sol';
import './Lot.sol';

/**
 * @title The market agent interface,
 *        market agent is contract presents a person on the market
 */
contract MarketAgent is Mortal {
    /**
     * @dev this event emitted for every lot placed on market
     */
    event LotPlaced(address indexed _lot);

    /**
     * @dev this event emitted for every lot deal done
     */
    event LotDeal(address indexed _lot);

    /**
     * @dev Place lot on the market
     * @param _name traded item term name
     * @param _token traded token
     * @param _value how much items traded
     * @param _price one item price
     * @return placed lot address for tracking
     */
    function put(string _name, TokenSpec _token,
                 uint _value,  uint _price) onlyOwner returns (Lot);

    /**
     * @dev Take a deal by given lot
     * @param _lot target lot address
     * @return `true` when deal is ok
     */
    function deal(Lot _lot) onlyOwner returns (bool);
}
