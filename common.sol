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

library AddressArray {
    /*** Insert item into array by position ***/
    function insert(address[] storage _data, uint _index, address _value) external {
        // Check correct index value
        if (_index >= _data.length) return;

        // Increase array length
        _data.length += 1;

        // Shift values
        for (uint i = _data.length-1; i > _index; --i)
            _data[i] = _data[i-1];

        // Set value for the index
        _data[_index] = _value;
    }

    /*** Remove item by index ***/
    function remove(address[] storage _data, uint _index) external {
        // Shift values
        for (uint i = _index; i < _data.length - 1; ++i)
            _data[i] = _data[i+1];

        // Decrese array length
        _data.length -= 1;
    }
    
    /*** Comparation procedure for two arrays ***/
    function isEqual(address[] _data, address[] _to) constant external returns (bool) {
        // Check count of items
        if (_data.length != _to.length)
            return false;

        // Check every item in the arrays
        for (uint i = 0; i < _data.length; ++i)
            if (_data[i] != _to[i])
                return false;
        return true;
    }

    /*** Find position of element in array ***/
    function indexOf(address[] _data, address _value) external returns (uint) {
        for (uint i = 0; i < _data.length; ++i)
            if (_data[i] == _value) return i;
        return _data.length;
    }
}
