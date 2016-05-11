import './TestCase.sol';

contract UnitTests is TestCase {
    TestCase[] public testList;

    event ErrorTest(address);
    event SuccessTest(address);
    
    function run() returns (bool) {
        var allIsOk = true;
        for (uint i = 0; i < testList.length; ++i) {
            // Run and make an event on error
            if (!testList[i].run()) {
                allIsOk = false;
                ErrorTest(testList[i]);
            } else {
                SuccessTest(testList[i]);
            }
        }
        return allIsOk;
    }
}
