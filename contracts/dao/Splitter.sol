pragma solidity ^0.4.4;
import 'common/Object.sol';

contract Splitter is Object {
    struct Holder {
        address account;
        uint8   part;
        uint    payout;
    }

    Holder[] public holders;
    mapping(address => uint) public holderId;

    function Splitter(address[] _accounts, uint8[] _parts) {
        if (_accounts.length != _parts.length) throw;

        uint8 sum = 0;
        for (uint i = 0; i < _accounts.length; ++i) {
            // Append holder
            holders.push(Holder(_accounts[i], _parts[i], 0));
            // Indexing by address
            holderId[_accounts[i]] = holders.length - 1;
            // Sum part
            sum += _parts[i];
        }
        // Check when parts correct
        if (sum != 100) throw;
    }

    /**
     * @dev Withdraw accumulated contract value according to ratio percent
     */
    function withdraw() {
        var id = holderId[msg.sender];
        if (holders[id].part == 0) throw;

        // Total holder value
        var value = totalReceived * holders[id].part / 100;

        // Check for payout
        if (value > holders[id].payout) {
            // Cacl payout diff
            var out = value - holders[id].payout;
            // Send difference
            if (!holders[id].account.send(out)) throw;
            holders[id].payout += out;
        }
    }

    /* Total received money to contract */
    uint public totalReceived = 0;

    /**
     * @dev Received log
     */
    function () payable {
        Received(msg.sender, msg.value);
        totalReceived += msg.value;
    }

    event Received(address indexed sender, uint indexed value);
}
