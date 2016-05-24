import './IPO.sol';

contract IPOFiniteTime is IPO {
    /* IPO params */ 
    uint public dateOfStart;
    uint public dateOfStop;

    uint public currentPrice;
    uint public currentPeriod;

    uint public priceStep;
    uint public stepPeriod;
    
    uint public ipoMinValue;
    uint public ipoEndValue;

    function IPOFiniteTime(address _credits, address _shares, uint _shares_count,
                           uint _duration_sec, uint _start_price, uint _step, uint _period_sec,
                           uint _min_value, uint _end_value) IPO(_credits, _shares, _shares_count) {
        dateOfStart   = now;
        dateOfStop    = dateOfStart + _duration_sec;
        currentPrice  = _start_price;
        currentPeriod = now;
        priceStep     = _step;
        stepPeriod    = _period_sec;
        ipoMinValue   = _min_value;
        ipoEndValue   = _end_value;
    }

    function sign() {
        if (closed) return;

        // Calculate shares price
        priceCalc();
        
        // Is termination need?
        if (terminationChecks()) return;

        // Detect sender credits value
        var value = credits.getBalance(msg.sender);
        if (value == 0) return;

        // Buy the shares
        var sharesCount = value / currentPrice;
        credits.transferFrom(msg.sender, this, value);
        shares.transfer(msg.sender, sharesCount);

        // Append sender as a new funder
        append(msg.sender, value);
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

    function terminationChecks() internal returns (bool) {
        // The date of stop passed
        if (now > dateOfStop) {
            if (ipoMinValue < credits.getBalance())
                // Minimal value funded
                done();
            else
                // No funded minimal value
                fail();

            return true;
        }

        // Funded maximal value
        if (ipoEndValue < credits.getBalance()) {
            done();
            return true;
        }

        return false;
    }
}
