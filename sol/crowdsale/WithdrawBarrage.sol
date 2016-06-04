import 'lib/AddressList.sol'; 
import 'common/Owned.sol';

contract WithdrawBarrage is Owned {
    /* Barrage params */
    uint public barrage_level = 100;
    uint public proposal_barrage = 100;

    /* Authority contract */
    mapping(address => bool) public authority;

    /* Value of 100% barrage */
    uint public full_balance_value = 0;

    /**
     * @dev Withdraw ethers for owner
     */
    function withdraw() onlyOwner {
        if (full_balance_value > 0) {
            var barrage_value = full_balance_value * barrage_level / 100;
            var value = this.balance - barrage_value; 
            if (value > 0) owner.send(value);
        }
    }

    /**
     * @dev Proposal a new barrage level
     * @param _value is a barrage level in percent 
     */
    function setBarrage(uint _value) onlyOwner
    { proposal_barrage = _value; }

    /**
     * @dev Approve barrage level in percent, only for authority
     * @param _value is a barrage level in percent 
     */
    function approveBarrage(uint _value) {
        if (authority[msg.sender] && _value == proposal_barrage)
            barrage_level = proposal_barrage;
    }
}
