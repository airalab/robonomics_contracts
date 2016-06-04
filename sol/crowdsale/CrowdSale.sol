import 'token/TokenEmission.sol';
import 'common/Owned.sol';
import 'common/FiniteTime.sol';

contract CrowdSale is Owned, FiniteTime {
    /* Crowdsale DAO token */
    TokenEmission public dao_token;

    /* Crowdsale credits */
    Token public credits;

    /* Price of one DAO token in Wei */
    uint public price_wei;
    uint public price_period;
    uint public price_step; 

    /* How amount wei are crowdsaled */
    uint public crowdsale_value = 0;

    /**
     * @dev Crowdsale constructor
     * @param _credits is a DAO credits token
     * @param _dao_token is a DAO token
     * @param _duration_sec is a crowdsale duration in seconds
     * @param _price_wei is a start price of one DAO token in Wei
     * @param _price_period is a period of price increments in second
     * @param _price_step is a price increment in percent e.g. 30% increment on each period
     * @notice DAO token should be delegated for me
     */
    function CrowdSale(address _credits, address _dao_token, uint _duration_sec,
                       uint _price_wei, uint _price_period, uint _price_step)
            FiniteTime(now, _duration_sec) {
        dao_token    = TokenEmission(_dao_token); 
        credits      = Token(_credits);
        price_wei    = _price_wei;
        price_period = _price_period;
        price_step   = _price_step;
    }

    function currentPrice() constant returns (uint) {
        var current_price = price_wei;
        var periods = (now - start_time) / price_period;
        for (uint i = 0; i < periods; ++i)
            current_price += price_wei * price_step / 100;
        return current_price;
    }

    /**
     * @dev Receive ethers for crowdsale
     */
    function () {
        // Check time for ending
        checkTime();

        // Handle received ethers
        if (msg.value > 0) {
            if (!is_alive) throw;

            var value = msg.value / currentPrice();
            dao_token.emission(value);
            dao_token.transfer(msg.sender, value);

            // Call hook code
            receiveHook(msg.sender, msg.value);
        }
    }

    /**
     * @dev Ethers received hook
     * @param _sender is an ether sender address
     * @param _value is a value of sended ethers
     */
    function receiveHook(address _sender, uint _value) internal {}
}
