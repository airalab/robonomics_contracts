import './CrowdSale.sol';
import './WithdrawBarrage.sol';

contract PlutusCrowdSale is CrowdSale, WithdrawBarrage {
    /**
     * @dev PlutusCrowdSale constructor
     * @param _credits is a DAO credits token
     * @param _dao_token is a DAO token
     * @param _duration_sec is a crowdsale duration in seconds
     * @param _price_wei is a start price of one DAO token in Wei
     * @param _price_period is a period of price increments in second
     * @param _price_step is a price increment in percent e.g. 30% increment on each period
     * @param _start_barrage is a start barrage value
     * @param _authority1 is a barrage curator contract
     * @param _authority2 is a barrage curator contract
     */
    function PlutusCrowdSale(address _credits, address _dao_token, uint _duration_sec,
                             uint _price_wei, uint _price_period, uint _price_step,
                             uint _start_barrage, address _authority1, address _authority2)
             CrowdSale(_credits, _dao_token, _duration_sec,
                       _price_wei, _price_period, _price_step) {
        barrage_level = _start_barrage;
        authority[_authority1] = true;
        authority[_authority2] = true;
    }

    uint public exchange_rate = 0; 
    mapping(address => bool) public isTokenExchanged;

    /**
     * @dev This method is run on crowdsale finish
     */
    function onFinish() internal {
        super.onFinish();
        exchange_rate = credits.getBalance() / dao_token.totalSupply(); 
        full_balance_value = this.balance;
    }

    /**
     * @dev exchange available DAO tokens to credits
     * @notice this method runs only once for one address
     */
    function exchange() {
        if (exchange_rate > 0 && !isTokenExchanged[msg.sender]) {
            credits.transfer(msg.sender,
                             dao_token.balanceOf(msg.sender) * exchange_rate);
            isTokenExchanged[msg.sender] = true;
        }
    }

    /*
     * Bonus tokens functionality
     */

    struct Bonus {
        uint start;
        uint stop;
        uint value;
    }

    Bonus[] bonus;

    /**
     * @dev Set bonus value
     * @param _start is a start time of bonus is active in UNIX time seconds 
     * @param _stop is a stop time of bonus
     * @param _value_percent is a bonus value in percent 
     */
    function setBonus(uint _start, uint _stop, uint _value_percent) onlyOwner {
        bonus[bonus.length++] = Bonus(_start, _stop, _value_percent);
    }

    function getBonus(uint _index) constant returns (uint, uint, uint) {
        var b = bonus[_index];
        return (b.start, b.stop, b.value);
    }


    /**
     * @dev Overloaded ethers receive hook
     * @param _sender is an ethers sender
     * @param _value is a sended value
     */
    function receiveHook(address _sender, uint _value) internal {
        for (uint8 i = 0; i < bonus.length; i += 1) {
            if (bonus[i].start < now && now < bonus[i].stop) {
                var bonus_value = _value / currentPrice() * bonus[i].value / 100;
                dao_token.emission(bonus_value);
                dao_token.transfer(_sender, bonus_value);
            }
        }
    }
}
