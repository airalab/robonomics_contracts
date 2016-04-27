import 'common.sol';
import 'token.sol';

library Voting {
    /* Voting structure */
    struct Poll {
        /* Stack of all voters */
        address[]                   voters;
        /* Count of shares for given voter */
        mapping(address => uint)    shareOf;
        /* Poll variant for given voter */
        mapping(address => address) pollOf;
        /* Current high voter variant, setted by `kingOfMountain` */
        address                     current;
    }

    using AddressArray for address[];
    using Voting for Poll;

    /**
     * @dev Calc poll of target and set current according
     *      to high vote results
     * @param _poll ref to `Poll` structure
     */
    function kingOfMountain(Poll storage _poll) {
        // Search the high voter
        var highVoter = _poll.voters[0];
        for (uint i = 0; i < _poll.voters.length; i += 1) {
            var voter = _poll.voters[i];
            if (_poll.shareOf[voter] > _poll.shareOf[highVoter])
                highVoter = voter;
        }
        _poll.current = _poll.pollOf[highVoter];
    }

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
        if (_poll.voters.indexOf(_voter) >= _poll.voters.length)
            _poll.voters.push(_voter);

        // Calc poll king
        _poll.kingOfMountain();
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

        // Calc poll king
        _poll.kingOfMountain();
    }
}
