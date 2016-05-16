import 'common/Mortal.sol';
import 'lib/CrowdSale.sol';
import './IPO.sol';

contract CashFlow is Mortal {
    Token public credits;
    Token public shares;

    mapping(address => CrowdSale.Item) itemOf;
    using CrowdSale for CrowdSale.Item;
 
    function CashFlow(Token _credits, Token _shares) {
        credits = _credits;
        shares  = _shares;
    }

    /**
     * @dev Get short item description
     * @param _target is item target address
     * @return item is closed, item goal value, item current value
     */
    function get(address _target) constant returns (bool, uint, uint) {
        return (itemOf[_target].closed,
                itemOf[_target].total,
                itemOf[_target].sum());
    }

    /**
     * @dev Get count of funders
     * @param _target is item address
     * @return count of funders
     */
    function getSize(address _target) constant returns (uint)
    { return itemOf[_target].voters.length; }

    /**
     * @dev Get how much
     * @param _target is item address
     * @param _index is founder index
     * @return funder address, funder value
     */
    function getValueOf(address _target, uint _index) constant returns (address, uint) {
        var voter = itemOf[_target].voters[_index];
        return (voter, itemOf[_target].valueOf[voter]);
    }

    /**
     * @dev Initial new crowdsale target
     * @param _target is an target address
     * @param _total is an target goal
     */
    function init(address _target, uint _total)
    { itemOf[_target].init(_target, _total); }
 
    event Fund(address indexed target, bool indexed result);

    /**
     * @dev Take a fund for the target
     * @param _target is an crowdsale target address
     * @notice You should approve shares for CashFlow before call fund
     */
    function fund(address _target)
    { Fund(_target,
      itemOf[_target].fund(msg.sender, shares, credits)); }
}
