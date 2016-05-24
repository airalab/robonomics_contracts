import 'lib/AddressList.sol';
import 'common/Mortal.sol';
import 'token/Token.sol';

contract CashFlow is Mortal {
    Token public credits;
    Token public shares;
 
    struct Item {
        uint total;
        bool closed;
        uint summary;
        AddressList.Data voters;
        mapping(address => uint) valueOf;
    }
    mapping(address => Item) itemOf;

    using AddressList for AddressList.Data;

    function CashFlow(address _credits, address _shares) {
        credits = Token(_credits);
        shares  = Token(_shares);
    }

    /**
     * @dev Get short item description
     * @param _target is item target address
     * @return item is closed, item goal value, item current value
     */
    function get(address _target) constant returns (bool, uint, uint) {
        return (itemOf[_target].closed,
                itemOf[_target].total,
                itemOf[_target].summary);
    }

    /**
     * @dev Get first of funders
     * @param _target is item address
     * @return funder address
     */
    function getFirstFunder(address _target) constant returns (address)
    { return itemOf[_target].voters.first(); }
 
    /**
     * @dev Get next of funders
     * @param _target is item address
     * @param _current is a current funder
     * @return funder address
     */
    function getFirstFunder(address _target, address _current) constant returns (address)
    { return itemOf[_target].voters.next(_current); }

    /**
     * @dev Get how much
     * @param _target is item address
     * @param _voter is funder address
     * @return funder value
     */
    function getValueOf(address _target, address _voter) constant returns (uint) {
        return itemOf[_target].valueOf[_voter];
    }

    /**
     * @dev Initial new crowdsale target
     * @param _target is an target address
     * @param _total is an target goal
     */
    function init(address _target, uint _total) { 
        itemOf[_target].total  = _total;
        itemOf[_target].closed = false;
    }
 
    event Fund(address indexed target, bool indexed result);

    /**
     * @dev Append new voter for crowdsale
     * @param _target is an target address
     * @param _count is a count of given shares
     */
    function fund(address _target, uint _count) {
        if (!shares.transferFrom(msg.sender, this, _count))
            throw;

        var item = itemOf[_target];

        item.valueOf[msg.sender] += _count;
        item.summary             += _count;

        var available = shares.totalSupply() - shares.getBalance();
        var scale     = credits.getBalance() / available;
        if (item.summary * scale >= item.total) {
            if (credits.transfer(_target, item.total))
                item.closed = true;
        }

        Fund(_target, itemOf[_target].closed);
    }
}
