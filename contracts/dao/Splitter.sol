pragma solidity ^0.4.4;
import 'common/Mortal.sol';
import 'token/TokenEther.sol';

contract Splitter is Mortal {
    address[] public destination;
    mapping(address => uint) public percent;

    /**
     * @dev Append new destination address
     * @param _destination is a destination address
     */
    function append(address _destination) onlyOwner
    { destination.push(_destination); }

    /**
     * @dev Set destination address and ratio
     * @param _destination is a destination address
     * @param _percent is a ratio in percent
     */
    function set(address _destination, uint _percent) onlyOwner
    { percent[_destination] = _percent; }

    /**
     * @dev Withdraw accumulated contract values, this method refill token balance
     *      and transfer to destinations according to ratio percent
     */
    function withdraw() onlyOwner {
        if (this.balance > 0) {
            /* XXX: possible DoS by block gas limit */
            for (uint i = 0; i < destination.length; ++i) {
                var part = percent[destination[i]];
                if (part > 0) {
                    var value = this.balance * 100 / part;
                    if (!destination[i].send(value)) throw;
                }
            }
        }
    }

    /**
     * @dev Received log
     */
    function () payable
    { Received(msg.sender, msg.value); }

    event Received(address indexed sender, uint indexed value);
}
