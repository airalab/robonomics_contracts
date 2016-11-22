pragma solidity ^0.4.4;
import 'token/Token.sol';
import './AddressList.sol';

/**
 * @dev The library for multiuser singletoken regulation.
 *      This data contains stack of variants sorted by value on its internal balance,
 *      any account(voter) can increase variant balance by self balance from given token,
 *      and any voter can decrease balance of variant but no more that given.
 *      The variant with high balance placed on top of voting pool and return by `current()`.
 */
library Voting {
    /* Voting structure */
    struct Poll {
        /* Stack of all voters */
        AddressList.Data            voters;
        /* Stack of all variants by value */
        AddressList.Data            variants;
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
    { return _poll.variants.first(); }

    /**
     * @dev Increase poll shares for given variant
     * @param _poll ref to `Poll` structure
     * @param _variant voter variant value
     * @param _shares token represents vote
     * @param _count how much votes are given
     */
    function up(Poll storage _poll, address _voter, address _variant,
                Token _shares, uint _count) {
        // Check for already voting for any variant
        if (_poll.pollOf[_voter] != 0 && _poll.pollOf[_voter] != _variant)
            throw;

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
        if (!_poll.variants.contains(_variant))
            _poll.variants.append(_variant);

        // Shift variant in the stack
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
        var variant = _poll.pollOf[_voter];

        // Transfer shares
        _shares.transfer(_voter, refund);
        _poll.shareOf[_voter]  -= refund;
        _poll.valueOf[variant] -= refund;

        // Clean voter poll
        if (_poll.shareOf[_voter] == 0) {
            _poll.pollOf[_voter] = 0;
            _poll.voters.remove(_voter);
        }

        // Shift right or drop when no shares
        if (_poll.valueOf[variant] > 0) {
            shiftRight(_poll, _poll.pollOf[_voter]);
        } else {
            _poll.variants.remove(variant);
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
        var left  = _poll.variants.prevOf[_variant];

        /* XXX: possible DoS by block gas limit
                when a lot of same value variants */
        while (left != 0 && _poll.valueOf[left] < value)
            left = _poll.variants.prevOf[left];

        _poll.variants.remove(_variant);
        if (left == 0) {
            _poll.variants.prepend(_variant);
        } else {
            _poll.variants.append(_variant, left);
        }
    }

    function shiftRight(Poll storage _poll, address _variant) internal {
        var value = _poll.valueOf[_variant];
        var right = _poll.variants.nextOf[_variant];

        /* XXX: possible DoS by block gas limit
                when a lot of same value variants */
        while (right != 0 && _poll.valueOf[right] > value)
            right = _poll.variants.nextOf[right];

        _poll.variants.remove(_variant);
        if (right == 0) {
            _poll.variants.append(_variant);
        } else {
            _poll.variants.prepend(_variant, right);
        }
    }
}
