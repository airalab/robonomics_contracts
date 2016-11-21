pragma solidity ^0.4.4;
import 'common/Mortal.sol';
import 'lib/AddressList.sol';
import 'token/TokenEther.sol';

contract Splitter is Mortal {
    TokenEther public token;

    /**
     * @dev Splitter constructor
     * @param _token_ether is a ether token
     */
    function Splitter(address _token_ether)
    { token = TokenEther(_token_ether); }

    event Received(address indexed sender, uint indexed value);
    event Transfer(address indexed to, uint indexed value);

    AddressList.Data destination;
    using AddressList for AddressList.Data;

    mapping(address => uint) public percent;

    /**
     * @dev Get first destination address
     * @return first address
     */
    function first() constant returns (address)
    { return destination.first(); }

    /**
     * @dev Get next destination address
     * @param _current is a current address
     * @return next address
     */
    function next(address _current) constant returns (address)
    { return destination.next(_current); }

    /**
     * @dev Count summary ratio of received values
     * @return summary percent of all destination
     */
    function summary() constant returns (uint) {
        uint sum = 0;
        for (var d = destination.first(); d != 0; d = destination.next(d))
            sum += percent[d];
        return sum;
    }

    /**
     * @dev Set destination address and ratio
     * @param _destination is a destination address
     * @param _percent is a ratio in percent
     */
    function set(address _destination, uint _percent) onlyOwner {
        if (_percent + summary() > 100) throw;

        if (!destination.contains(_destination))
            destination.append(_destination);

        percent[_destination] = _percent;
    }

    /**
     * @dev Remove destination from list
     * @param _destination is a destination to remove
     */
    function remove(address _destination) onlyOwner
    { destination.remove(_destination); }

    /**
     * @dev Withdraw accumulated contract values, this method refill token balance
     *      and transfer to destinations according to ratio percent
     */
    function withdraw() onlyOwner {
        if (this.balance > 0) {
            token.refill.value(this.balance)();
            var balance = token.getBalance();

            /* XXX: possible DoS by block gas limit */
            for (var d = destination.first(); d != 0; d = destination.next(d)) {
                var value = balance * 100 / percent[d];
                if (!token.transfer(d, value)) throw;
                Transfer(d, value);
            }
        }
    }

    /**
     * @dev Received log
     */
    function()
    { Received(msg.sender, msg.value); }
}
