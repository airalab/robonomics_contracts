import 'unit.sol';

contract Empty {}

contract AppendTest is TestCase {
    Array.Data data;
    address public address0 = new Empty();
    address public address1 = new Empty();
    address public address2 = new Empty();
    
    function get(uint i) returns (address)
    { return Array.get(data, i); }
    
    function run() returns (bool) {
        Array.append(data, address0);
        Array.append(data, address1);
        Array.append(data, address2);
        
        var success = Array.get(data, 0) == address0
                   && Array.get(data, 1) == address1
                   && Array.get(data, 2) == address2;
        return success;
    }
}

contract InsertTest is TestCase {
    Array.Data data;
    address public address0 = new Empty();
    address public address1 = new Empty();
    address public address2 = new Empty();
    
    function run() returns (bool) {
        Array.append(data, address0);
        Array.append(data, address1);
        Array.insert(data, 1, address2);
        
        var success = Array.get(data, 0) == address0
                   && Array.get(data, 1) == address2
                   && Array.get(data, 2) == address1;
        return success;
    }
}

contract IteratorTest is TestCase {
    Array.Data data;
    Array.Iterator it;
    address public address0 = new Empty();
    address public address1 = new Empty();
    address public address2 = new Empty();
    
    function run() returns (bool) {
        Array.append(data, address0);
        Array.append(data, address1);
        Array.append(data, address2);
        
        Array.setEnd(data, it);
        if (!Array.end(it))
            return false;
        
        Array.setBegin(data, it);
        if (Array.get(it) != address0 && !Array.begin(it))
            return false;

        Array.next(it);
        if (Array.get(it) != address1)
            return false;
        
        Array.next(it);
        if (Array.get(it) != address2)
            return false;
            
        Array.next(it);
        return Array.end(it);
    }
}

contract ArrayTests is UnitTests {
    function ArrayTests() {
        append(new AppendTest());
        append(new InsertTest());
        append(new IteratorTest());
    }
}
