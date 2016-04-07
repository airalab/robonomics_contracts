import 'common.sol';

/* Unit test interface */
contract TestCase {
    /* This field is a short test description */
    string public name;

    /* This method contains single check
     * and returns true when all is OK */
    function run() returns (bool);
}

contract UnitTests is TestCase {
    TestCase[] public tests;

    event ErrorTest(address);
    event SuccessTest(address);
    
    bool public passed = false;

    function run() returns (bool) {
        var allIsOk = true;
        for (uint i = 0; i < tests.length; ++i) {
            // Take a current case
            var test = TestCase(tests[i]);

            // Run and make an event on error
            if (!test.run()) {
                allIsOk = false;
                ErrorTest(test);
            } else {
                SuccessTest(test);
            }
        }
        passed = allIsOk;
        return allIsOk;
    }
}
