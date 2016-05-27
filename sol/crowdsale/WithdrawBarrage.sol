import 'voting/Voting51.sol';

contract WithdrawBarrage is Owned {
    /* Barrage params */
    uint[] public barrage_level;
    uint public current_barrage = 0;

    /* Authority contract */
    address public authority;

    /* Value of 100% barrage */
    uint public full_balance_value = 0;

    /**
     * @dev Withdraw ethers for owner
     */
    function withdraw() onlyOwner {
        if (full_balance_value > 0) {
            var barrage_value = full_balance_value / 100 * barrage_level[current_barrage];
            var value = this.balance - barrage_value; 
            if (value > 0) owner.send(value);
        }
    }

    /**
     * @dev Change barrage level, only for authority contract
     */
    function() {
        if (msg.sender == authority)
            ++current_barrage;
    }
}
