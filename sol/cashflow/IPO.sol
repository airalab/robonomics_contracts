import 'common/Mortal.sol';
import 'common/FiniteTime.sol';
import 'token/TokenEmission.sol';
import './CashFlow.sol';

contract IPO is FiniteTime, Owned {
    CashFlow public cashflow;

    /* IPO fail notification */
    bool public is_fail = false;
    event Failed();

    /* The funders storage */
    address[] public funders;
    mapping(address => uint) public creditsOf;

    uint public currentPrice;
    uint public currentPeriod;
    uint public priceStep;
    uint public stepPeriod;
    
    uint public ipoMinValue;
    uint public ipoEndValue;
    
    function IPO(address _cashflow, uint _start_time_sec, uint _duration_sec,
                 uint _start_price, uint _step, uint _period_sec,
                 uint _min_value, uint _end_value) FiniteTime(_start_time_sec, _duration_sec) {
        owner         = msg.sender;
        cashflow      = CashFlow(_cashflow);
        currentPrice  = _start_price;
        currentPeriod = _start_time_sec;
        priceStep     = _step;
        stepPeriod    = _period_sec;
        ipoMinValue   = _min_value;
        ipoEndValue   = _end_value;
    }

    /**
     * @dev Available shares getter
     * @return available shares value
     */
    function getFreeShares() constant returns (uint)
    { return cashflow.shares().getBalance(); }

    /**
     * @dev Founded credits getter
     * @return founded credits value
     */
    function getFoundedCredits() constant returns (uint)
    { return cashflow.credits().getBalance(); }

    /**
     * @dev This method is called when user accept the IPO
     * @notice Some credits should be approved for IPO before call 
     */
    function sign() {
        checkTime();

        // Wnen now is end of time
        if (now > end_time) {
            if (ipoMinValue < cashflow.credits().getBalance())
                // Minimal value funded
                done();
            else
                // No funded minimal value
                fail();
            return;
        }

        // Funded maximal value
        if (ipoEndValue < cashflow.credits().getBalance()) {
            done();
            return;
        }

        // Not alowed to start
        if (!is_alive) return;

        // Calculate shares price
        priceCalc();
        
        // Detect sender credits value
        var value = cashflow.credits().getBalance(msg.sender);
        if (value == 0) return;

        // Buy the shares
        var sharesCount = value / currentPrice;
        if (!cashflow.credits().transferFrom(msg.sender, this, value)) throw;
        if (!cashflow.shares().transfer(msg.sender, sharesCount)) throw;

        // Append sender as a new funder
        funders.push(msg.sender);
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
     * @dev This internal method should be called when IPO closed success
     */
    function done() internal {
        // Refund owner unused shares
        if (!cashflow.shares().transfer(owner, cashflow.shares().getBalance()))
            throw;

        // Transfer funded credits to cashflow
        if (!cashflow.credits().transfer(cashflow, cashflow.credits().getBalance()))
            throw;

        // Close the IPO
        is_alive = false;
        Finish();
    }

    /**
     * @dev This internal method should be called when IPO closed fail
     */
    function fail() internal {
        // Refund owner unused shares
        if (!cashflow.shares().transfer(owner, cashflow.shares().getBalance()))
            throw;

        // Close the IPO
        is_fail = true;
        is_alive = false;
        Failed();
    }

    
    /**
     * @dev Refund sended credits when IPO is fail
     */
    function refund() {
        if (creditsOf[msg.sender] > 0 && is_fail)
            if (!cashflow.credits().transfer(msg.sender, creditsOf[msg.sender]))
                throw;
    }
}
