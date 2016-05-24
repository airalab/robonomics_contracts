import 'token/Token.sol';
import './AddressList.sol';

/**
 * @dev The library for voting actions.
 *      This data contains stack of voters, its opinion and count of shares.
 */
library Voting {
    /* Voting structure */
    struct Poll {
        /* Stack of all voters by value */
        AddressList.Data            voters;
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
    { return _poll.pollOf[_poll.voters.first()]; } 

    /**
     * @dev Increase poll shares for given variant
     * @param _poll ref to `Poll` structure
     * @param _value voter variant value
     * @param _shares token represents vote
     * @param _count how much votes are given
     */
    function up(Poll storage _poll, address _voter, address _value,
                Token _shares, uint _count) {
        // Try to transfer count of shares from voter to self
        if (!_shares.transferFrom(_voter, this, _count))
            throw;

        // Increase shares and set the poll
        _poll.shareOf[_voter] += _count;
        _poll.pollOf[_voter]   = _value;

        // Append voter if not in list
        if (!_poll.voters.contains(_voter))
            _poll.voters.append(_voter);

        // Shift voter in the stack
        shiftLeft(_poll, _voter);
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
        _poll.shareOf[_voter] -= refund;

        // Shift right or drop when no shares
        if (_poll.shareOf[_voter] > 0) {
            shiftRight(_poll, _voter);
        } else {
            _poll.voters.remove(_voter);
        }
    }

    /*
     * Shifting mechanism
     * Thesys: the stack of voters should be sorted by shareOf value.
     * Solution:
     *  - `up` call: voter shifted left while his shareOf value is large
     *  - `down` call: voter shifted right in the stack while shareOf value is low
     */

    function shiftLeft(Poll storage _poll, address _voter) internal {
        var value = _poll.shareOf[_voter];
        var left  = _poll.voters.prev(_voter);

        while (left != 0 && _poll.shareOf[left] < value) {
            _poll.voters.swap(left, _voter);
            left = _poll.voters.prev(_voter);
        }
    }

    function shiftRight(Poll storage _poll, address _voter) internal {
        var value = _poll.shareOf[_voter];
        var right = _poll.voters.next(_voter);

        while (right != 0 && _poll.shareOf[right] > value) {
            _poll.voters.swap(right, _voter);
            right = _poll.voters.next(_voter);
        }
    }
}
