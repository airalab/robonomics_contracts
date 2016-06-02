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
     * @param _first_barrage is a barrage value for first iteration 
     * @param _second_barrage is a barrage value for second iteration
     * @param _authority1 is a barrage first authority contract
     * @param _authority2 is a barrage second authority contract
     * @param _authority3 is a barrage third authority contract
     */
    function PlutusCrowdSale(address _credits, address _dao_token, uint _duration_sec,
                             uint _price_wei, uint _price_period, uint _price_step,
                             uint _start_barrage, uint _first_barrage, uint _second_barrage,
                             address _authority1, address _authority2, address _authority3)
             CrowdSale(_credits, _dao_token, _duration_sec,
                       _price_wei, _price_period, _price_step) {
        barrage_level.push(_start_barrage);
        barrage_level.push(_first_barrage);
        barrage_level.push(_second_barrage);
        authority[_authority1] = true;
        authority[_authority2] = true;
        authority[_authority3] = true;
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
}
