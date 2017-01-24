pragma solidity ^0.4.4;
import 'common/Object.sol';
import 'common/FiniteTime.sol';
import 'token/TokenEmission.sol';

contract CrowdSale is FiniteTime, Object {
    address public target;
    Token   public credits;
    Token   public sale;

    /* fail notification */
    bool public is_fail = false;
    event Failed();

    uint public currentPrice;
    uint public currentPeriod;
    uint public priceStep;
    uint public stepPeriod;
    
    uint public minValue;
    uint public endValue;

    mapping(address => uint) public creditsOf;
 
    /**
     * @dev Crowdsale contract constructor
     * @param _target is a target address for send given credits of success end
     * @param _credits is a DAO fund token
     * @param _sale is a saled token
     * @param _start_time_sec is a start time of Crowdsale in UNIX time
     * @param _duration_sec is a duration of Crowdsale in seconds
     * @param _start_price is a start price of one `_sale` token in credits
     * @param _step is a step of price up in percent
     * @param _period_sec is a period of price grown in seconds
     * @param _min_value is a minimal value for successfull Crowdsale ending
     * @param _end_value is a value when given for immediate Crowdsale ending
     */
    function CrowdSale(address _target, address _credits, address _sale,
                       uint _start_time_sec, uint _duration_sec,
                       uint _start_price, uint _step, uint _period_sec,
                       uint _min_value, uint _end_value) FiniteTime(_start_time_sec, _duration_sec)
    {
        owner         = msg.sender;
        target        = _target;
        credits       = Token(_credits);
        sale          = Token(_sale);
        currentPrice  = _start_price;
        currentPeriod = _start_time_sec;
        priceStep     = _step;
        stepPeriod    = _period_sec;
        minValue      = _min_value;
        endValue      = _end_value;
    }

    /**
     * @dev This method is called when user accept
     * @notice Some credits should be approved for before call 
     */
    function deal() {
        checkTime();

        // Wnen now is end of time
        if (now > end_time) {
            if (minValue < credits.balanceOf(this))
                // Minimal value funded
                done();
            else
                // No funded minimal value
                fail();
            return;
        }

        // Funded maximal value
        if (endValue < credits.balanceOf(this)) {
            done();
            return;
        }

        // Not alowed to start
        if (!is_alive) return;

        // Calculate price
        priceCalc();
        
        // Detect sender credits value
        var value = credits.allowance(msg.sender, this)
                  > credits.balanceOf(msg.sender)
                  ? credits.balanceOf(msg.sender)
                  : credits.allowance(msg.sender, this);
        if (value == 0) return;

        // Buy the
        var count = value / currentPrice;
        if (!credits.transferFrom(msg.sender, this, value)) throw;
        if (!sale.transfer(msg.sender, count)) throw;

        // Store given value for refund when fail
        creditsOf[msg.sender] += value;
    }

    function priceCalc() internal {
        // Calc how much periods passed
        var stepCount = (now - currentPeriod) / stepPeriod;

        // Increase price for periods
        for (uint i = 0; i < stepCount; i += 1)
            currentPrice += currentPrice * priceStep / 100; 

        // Increase current period
        currentPeriod += stepPeriod * stepCount;
    }

    /**
     * @dev This internal method should be called when closed success
     */
    function done() internal {
        // Refund owner unused
        if (!sale.transfer(owner, sale.balanceOf(this)))
            throw;

        // Transfer funded credits to target
        if (!credits.transfer(target, credits.balanceOf(this)))
            throw;

        // Close the IPO
        is_alive = false;
        Finish();
    }

    /**
     * @dev This internal method should be called when closed fail
     */
    function fail() internal {
        // Refund owner unused sale
        if (!sale.transfer(owner, sale.balanceOf(this)))
            throw;

        // Close the IPO
        is_fail = true;
        is_alive = false;
        Failed();
    }

    
    /**
     * @dev Refund sended credits when is fail
     */
    function refund() {
        if (creditsOf[msg.sender] > 0 && is_fail)
            if (!credits.transfer(msg.sender, creditsOf[msg.sender]))
                throw;
    }
}
