import 'lib/AddressList.sol';
import 'common/Mortal.sol';
import 'token/Token.sol';

contract CashFlow is Mortal {
    Token public credits;
    Token public shares;
 
    event TargetUpdated(address indexed target, bool indexed closed);
 
    struct Item {
        uint total;
        bool closed;
        uint summary;
        AddressList.Data voters;
        mapping(address => uint) valueOf;
    }

    mapping(address => Item) itemOf;
    AddressList.Data targets;

    using AddressList for AddressList.Data;

    function CashFlow(address _credits, address _shares) {
        credits = Token(_credits);
        shares  = Token(_shares);
    }

    /**
     * @dev Get first target
     * @return first target
     */
    function firstTarget() constant returns (address)
    { return targets.first(); }

    /**
     * @dev Get next target
     * @param _current is a current target
     * @return next target
     */
    function nextTarget(address _current) constant returns (address)
    { return targets.next(_current); }

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
    function firstFunder(address _target) constant returns (address)
    { return itemOf[_target].voters.first(); }
 
    /**
     * @dev Get next of funders
     * @param _target is item address
     * @param _current is a current funder
     * @return funder address
     */
    function nextFunder(address _target, address _current) constant returns (address)
    { return itemOf[_target].voters.next(_current); }

    /**
     * @dev Get how much
     * @param _target is item address
     * @param _voter is funder address
     * @return funder value
     */
    function getValueOf(address _target, address _voter) constant returns (uint)
    { return itemOf[_target].valueOf[_voter]; }

    /**
     * @dev Initial new crowdsale target
     * @param _target is an target address
     * @param _total is an target goal
     */
    function init(address _target, uint _total) { 
        itemOf[_target].total  = _total;
        itemOf[_target].closed = false;
        targets.append(_target);
    }

    /**
     * @dev Append new voter for crowdsale
     * @param _target is an target address
     * @param _value is a count of given shares
     */
    function fund(address _target, uint _value) {
        if (!shares.transferFrom(msg.sender, this, _value))
            throw;

        var item = itemOf[_target];
        if (!item.voters.contains(msg.sender))
            item.voters.append(msg.sender);
        item.valueOf[msg.sender] += _value;
        item.summary             += _value;

        var available = shares.totalSupply() - shares.getBalance();
        var scale     = credits.getBalance() / available;
        if (item.summary * scale >= item.total) {
            if (credits.transfer(_target, item.total))
                item.closed = true;
        }

        TargetUpdated(_target, itemOf[_target].closed);
    }

    /**
     * @dev Decrease self share value from target
     * @param _target is a crowdsale target
     * @param _value is how amount shares will be refunded
     */
    function refund(address _target, uint _value) {
        var item = itemOf[_target];
        var refund_value = item.valueOf[msg.sender] > _value
                         ? _value : item.valueOf[msg.sender]; 

        // Refund shares
        shares.transfer(msg.sender, refund_value);

        // Decrease values
        item.valueOf[msg.sender] -= refund_value;
        item.summary             -= refund_value;

        // Remove voter if balance is zero
        if (item.valueOf[msg.sender] == 0)
            item.voters.remove(msg.sender);
    }
}
