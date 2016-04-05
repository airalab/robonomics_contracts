/*
 * Contract for object that have an owner
 */
contract Owned {
    /* Contract owner address */
    address public owner;

    /* Store owner on creation */
    function Owned() { owner = msg.sender; }

    /* Delegate contract to another person */
    function delegate(address _owner) onlyOwner
    { owner = _owner; }

    /* Owner check modifier */
    modifier onlyOwner { if (msg.sender == owner) _ }
}

/*
 * Contract for objects that can be morder
 */
contract Mortal is Owned {
    /* Only owner can kill me */
    function kill() onlyOwner {
        suicide(owner);
    }
}

library Array {
    struct Data {
        address [] values;
    }
    
    struct Iterator {
        Data data;
        uint ix;
    }
    
    function size(Data storage _data) constant returns (uint) {
        return _data.values.length;
    }
    
    function get(Data storage _data, uint _index) constant returns (address) {
        return _data.values[_index];
    }

    function append(Data storage _data, address _value) {
        // Increse array length and store value
        _data.values[_data.values.length++] = _value;
    }

    function insert(Data storage _data, uint _index, address _value) {
        // Increse array length
        _data.values.length += 1;
        // Shift values
        for (uint i = _data.values.length - 1; i >= _index; --i)
            _data.values[i+1] = _data.values[i];
        // Set value for the index
        _data.values[_index] = _value;
    }

    function remove(Data storage _data, uint _index) {
        // Shift values
        for (uint i = _index; i < _data.values.length - 1; ++i)
            _data.values[i] = _data.values[i+1];
        // Decrese array length
        _data.values.length -= 1;
    }

    function remove(Iterator storage _it) {
        if (!end(_it)) remove(_it.data, _it.ix);
    }

    function remove(Iterator storage _it, address _item) {
        setBegin(_it.data, _it);
        find(_it, _item);
        remove(_it);
    }
    
    function isEqual(Data storage _data, Data storage _to) constant returns (bool) {
        // Check count of items
        if (_data.values.length != _to.values.length)
            return false;
        // Check every item in the arrays
        for (uint i = 0; i < _data.values.length; i += 1)
            if (_data.values[i] != _to.values[i])
                return false;
        return true;
    }

    function begin(Iterator storage _it) constant returns (bool) {
        return 0 == _it.ix;
    }

    function end(Iterator storage _it) constant returns (bool) {
        return _it.data.values.length == _it.ix;
    }
    
    function setBegin(Data storage _data, Iterator storage _it) {
        _it.data = _data;
        _it.ix = 0;
    }

    function setEnd(Data storage _data, Iterator storage _it) {
        _it.data = _data;
        _it.ix = _data.values.length;
    }

    function next(Iterator storage _it) returns (bool) {
        return _it.ix++ < _it.data.values.length;
    }

    function get(Iterator storage _it) constant returns (address) {
        return _it.data.values[_it.ix];
    }

    function find(Iterator storage _it, address _value) {
        while (!end(_it)) {
            if (get(_it) == _value)
                return;
            next(_it);
        }
    }
}
