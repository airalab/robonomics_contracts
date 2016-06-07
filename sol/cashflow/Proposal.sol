import 'common/Owned.sol';
import 'lib/AddressList.sol';

contract Proposal is Owned {
    // Constructor
    function Proposal(address _target, uint _total) {
        target      = _target;
        total_value = _total;
    }

    // Proposal destination address
    address public target;

    // Proposal value in credits
    uint public total_value;
    
    // Is proposal closed?
    bool public closed = false;

    // Current summary shares given
    uint public summary = 0;

    // Current given shares by funder address
    mapping(address => uint) public valueOf;

    // Amount of credits returned
    uint public total_back = 0;

    // Current released shares
    mapping(address => uint) public backOf;
 
    // Current share price
    uint public share_price = 0;

    AddressList.Data funders;
    using AddressList for AddressList.Data;

    function append(address _funder, uint _value, uint _price) onlyOwner {
        if (!funders.contains(_funder))
            funders.append(_funder);

        valueOf[_funder] += _value;
        summary          += _value;
        share_price       = _price;

        if (summary * share_price >= total_value)
            closed = true;
    }

    function remove(address _funder, uint _value) onlyOwner returns (uint) {
        var refund_value = valueOf[_funder] > _value
                         ? _value : valueOf[_funder]; 

        // Decrease values
        valueOf[_funder] -= refund_value;
        summary          -= refund_value;

        // Remove voter if balance is zero
        if (valueOf[_funder] == 0)
            funders.remove(_funder);

        return refund_value;
    }

    function fundback(address _funder, uint _value) onlyOwner returns (uint) {
        total_back      += _value;
        var back_value  = valueOf[_funder] * total_back / total_value;
        var free_shares = back_value <= valueOf[_funder]
                        ? back_value : valueOf[_funder];
        var refund = free_shares - backOf[_funder];
        backOf[_funder] = free_shares;
        return refund;
    }
}
