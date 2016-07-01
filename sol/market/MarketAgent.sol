import 'thesaurus/Knowledge.sol';
import 'token/Token.sol';
import './Lot.sol';

/**
 * @title The market agent interface,
 *        market agent is contract presents a person on the market
 */
contract MarketAgent is Mortal {
    /**
     * @dev this event emitted for every lot deal done
     */
    event LotDeal(address indexed _lot);

    /**
     * @dev Take a deal by given lot
     * @param _lot target lot address
     * @return `true` when deal is ok
     */
    function deal(Lot _lot) onlyOwner returns (bool);
}
