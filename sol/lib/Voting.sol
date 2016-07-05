import 'token/Token.sol';
import './AddressList.sol';

/**
 * @dev The library for voting actions.
 *      This data contains stack of voters, its opinion and count of shares.
 */
library Voting {
    /* Voting structure */
    struct Poll {
        /* Stack of all voters */
        AddressList.Data            voters;
        /* Stack of all variants by value */
        AddressList.Data            poll;
        /* Count of shares for given variant */
        mapping(address => uint)    valueOf;
        /* Count of shares for given voter */
        mapping(address => uint)    shareOf;
        /* Poll variant for given voter */
        mapping(address => address) pollOf;
    }

    using AddressList for AddressList.Data;

    /**
     * @dev Current high value poll
     * @param _poll ref to `Poll` structure
     * @return current value
     */
    function current(Poll storage _poll) constant returns (address)
    { return _poll.poll.first(); } 

    /**
     * @dev Increase poll shares for given variant
     * @param _poll ref to `Poll` structure
     * @param _variant voter variant value
     * @param _shares token represents vote
     * @param _count how much votes are given
     */
    function up(Poll storage _poll, address _voter, address _variant,
                Token _shares, uint _count) {
        // Try to transfer count of shares from voter to self
        if (!_shares.transferFrom(_voter, this, _count))
            throw;

        // Increase shares and set the poll
        _poll.shareOf[_voter]   += _count;
        _poll.pollOf[_voter]     = _variant;
        _poll.valueOf[_variant] += _count;

        // Append voter if not in list
        if (!_poll.voters.contains(_voter))
            _poll.voters.append(_voter);

        // Append variant if not in list
        if (!_poll.poll.contains(_variant))
            _poll.poll.append(_variant);

        // Shift voter in the stack
        shiftLeft(_poll, _variant);
    }

    /**
     * @dev Decrease poll shares of given voter
     * @param _poll ref to `Poll` structure
     * @param _count how much shares will decreased
     */
    function down(Poll storage _poll, address _voter, Token _shares, uint _count) {
        // So I can refund no more that gives from voter 
        var refund = _poll.shareOf[_voter] > _count ? _count : _poll.shareOf[_voter];

        // Transfer shares
        _shares.transfer(_voter, refund);
        _poll.shareOf[_voter]               -= refund;
        _poll.valueOf[_poll.pollOf[_voter]] -= refund;

        // Shift right or drop when no shares
        if (_poll.shareOf[_voter] > 0) {
            shiftRight(_poll, _poll.pollOf[_voter]);
        } else {
            _poll.voters.remove(_voter);
        }
    }

    /*
     * Shifting mechanism
     * Thesys: the stack of variants should be sorted by valueOf value.
     * Solution:
     *  - `up` call: variant shifted left while his valueOf value is large
     *  - `down` call: varian shifted right in the stack while valueOf value is low
     */

    function shiftLeft(Poll storage _poll, address _variant) internal {
        var value = _poll.valueOf[_variant];
        var left  = _poll.poll.prev(_variant);

        while (left != 0 && _poll.valueOf[left] < value) {
            _poll.poll.swap(left, _voter);
            left = _poll.poll.prev(_variant);
        }
    }

    function shiftRight(Poll storage _poll, address _variant) internal {
        var value = _poll.valueOf[_variant];
        var right = _poll.poll.next(_variant);

        while (right != 0 && _poll.valueOf[right] > value) {
            _poll.poll.swap(right, _variant);
            right = _poll.poll.next(_variant);
        }
    }
}
