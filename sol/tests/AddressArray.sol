import './UnitTests.sol';
import 'lib/AddressArray.sol';

contract InsertTest is TestCase {
    using AddressArray for address[];
    address[] public data;

    address public address0 = 0x36cc51e5a1a3df455daaed83a746acfce28f37d7;
    address public address1 = 0x46cc51e5a1a3df455daaed83a746acfce28f37d7;
    address public address2 = 0x56cc51e5a1a3df455daaed83a746acfce28f37d7;

    function InsertTest() { name = "Array insert test"; }

    function push(address _item)
    { data.push(_item); }

    function run() returns (bool) {
        data.push(address0);
        data.push(address1);
        data.insert(1, address2);
        
        var success = data[0] == address0
                   && data[1] == address2
                   && data[2] == address1;
        return success;
    }
}

contract FindTest is TestCase {
    using AddressArray for address[];
    address[] public data;

    address public address0 = 0x36cc51e5a1a3df455daaed83a746acfce28f37d7;
    address public address1 = 0x46cc51e5a1a3df455daaed83a746acfce28f37d7;
    address public address2 = 0x56cc51e5a1a3df455daaed83a746acfce28f37d7;
    
    function FindTest() { name = "Array find test"; }
    
    function run() returns (bool) {
        data.push(address0);
        data.push(address1);
        data.push(address2);
        
        return data.indexOf(address1) == 1
            && data.indexOf(address2) == 2
            && data.indexOf(address0) == 0;
    }
}

contract ArrayTests is UnitTests {
    function ArrayTests() {
        testList.push(new InsertTest());
        testList.push(new FindTest());
    }
}
