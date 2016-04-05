import 'common.sol';

/* Unit test interface */
contract TestCase is Mortal {
    /* This method contains single check
     * and returns true when all is OK */
    function run() returns (bool);
}

contract UnitTests is TestCase {
    Array.Data tests;
    Array.Iterator it;

    event ErrorOnTest(uint number);

    function run() returns (bool) {
        var allIsOk = true;
        Array.setBegin(tests, it);
        while (!Array.end(it)) {
            // Take a current case
            var test = TestCase(Array.get(it));
            // Run and make an event on error
            if (!test.run()) {
                allIsOk = false;
                ErrorOnTest(it.ix);
            }
        }
    }

    function append(TestCase _case) {
        Array.append(tests, _case);
    }
}
