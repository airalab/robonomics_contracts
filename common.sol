/// @title Common using libraries and contracts

/**
 * @title Contract for object that have an owner
 */
contract Owned {
    /**
     * Contract owner address
     */
    address public owner;

    /**
     * @dev Store owner on creation
     */
    function Owned() { owner = msg.sender; }

    /**
     * @dev Delegate contract to another person
     * @param _owner another person address
     */
    function delegate(address _owner) onlyOwner
    { owner = _owner; }

    /**
     * @dev Owner check modifier
     */
    modifier onlyOwner { if (msg.sender == owner) _ }
}

/**
 * Contract for objects that can be morder
 */
contract Mortal is Owned {
    /**
	 * @dev Destroy contract and scrub a data
     * @notice Only owner can kill me
     */
    function kill() onlyOwner
    { suicide(owner); }
}

/**
 * @title Array of addreses extention
 */
library AddressArray {
    /**
     * @dev Insert item into array by position
     * @param _data is an address array
     * @param _index position for a new element
     * @param _value new element value
     */
    function insert(address[] storage _data, uint _index, address _value) {
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

    /**
     * @dev Remove item by it position 
     * @param _data is an address array 
     * @param _index position of removed element
     */
    function remove(address[] storage _data, uint _index) {
        // Shift values
        for (uint i = _index; i < _data.length - 1; ++i)
            _data[i] = _data[i+1];

        // Decrese array length
        _data.length -= 1;
    }
    
    /**
     * @dev Comparation procedure for two arrays 
     * @param _data first array for compare
     * @param _to second array for compare
     * @return `true` when arrays is equal
     */
    function isEqual(address[] _data, address[] _to) constant returns (bool) {
        // Check count of items
        if (_data.length != _to.length)
            return false;

        // Check every item in the arrays
        for (uint i = 0; i < _data.length; ++i)
            if (_data[i] != _to[i])
                return false;
        return true;
    }

    /** 
     * @dev Search an element position in array 
     * @param _data is an address array  
     * @param _value is an target address
     * @return position of element or array length if not found
     */
    function indexOf(address[] _data, address _value) external returns (uint) {
        for (uint i = 0; i < _data.length; ++i)
            if (_data[i] == _value) return i;
        return _data.length;
    }
}
