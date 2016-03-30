/*
 * Contract for object that have an owner
 */
contract Owned {
    /* Contract owner address */
    address public owner;

    /* Store owner on creation */
    function Owned() { owner = msg.sender; }

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

library StringArray {
	struct Data {
		string [] values;
	}
	
	struct Iterator {
	    Data data;
	    uint ix;
	}
	
	function size(Data storage _data) returns (uint) {
	    return _data.values.length;
	}
	
	function get(Data storage _data, uint _index) returns (string) {
		return _data.values[_index];
	}

	function append(Data storage _data, string _value) {
		// Increse array length and store value
		_data.values[_data.values.length++] = _value;
	}

	function insert(Data storage _data, uint _index, string _value) {
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
	
	function isEqual(Data storage _data, Data storage _to) returns (bool) {
	    // Check count of items
	    if (_data.values.length != _to.values.length)
	        return false;
	    // Check every item in the arrays
	    for (uint i = 0; i < _data.values.length; i += 1)
	        if (sha3(_data.values[i]) != sha3(_to.values[i]))
	            return false;
	    return true;
	}

	function begin(Data storage _data, Iterator storage _it) returns (bool) {
	    if (isEqual(_data, _it.data) && 0 == _it.ix)
	        return true;
		return false;
	}

	function end(Data storage _data, Iterator storage _it) returns (bool) {
	    if (isEqual(_data, _it.data) && _data.values.length == _it.ix)
	        return true;
		return false;
	}

	function next(Iterator storage _it) returns (bool) {
		return _it.ix++ < _it.data.values.length;
	}

	function get(Iterator storage _it) returns (string) {
		return _it.data.values[_it.ix];
	}

	function find(Data storage _data, Iterator storage _it, string _value) {
	    begin(_data, _it);
		findNext(_data, _it, _value);
	}

	function findNext(Data storage _data, Iterator storage _it, string _value) {
		while (next(_it))
			if (sha3(get(_it)) == sha3(_value))
				return;
	}

	function remove(Iterator storage _it) {
		remove(_it.data, _it.ix);
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
	
	function size(Data storage _data) returns (uint) {
	    return _data.values.length;
	}
	
	function get(Data storage _data, uint _index) returns (address) {
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
	
	function isEqual(Data storage _data, Data storage _to) returns (bool) {
	    // Check count of items
	    if (_data.values.length != _to.values.length)
	        return false;
	    // Check every item in the arrays
	    for (uint i = 0; i < _data.values.length; i += 1)
	        if (_data.values[i] != _to.values[i])
	            return false;
	    return true;
	}

	function begin(Data storage _data, Iterator storage _it) returns (bool) {
	    if (isEqual(_data, _it.data) && 0 == _it.ix)
	        return true;
		return false;
	}

	function end(Data storage _data, Iterator storage _it) returns (bool) {
	    if (isEqual(_data, _it.data) && _data.values.length == _it.ix)
	        return true;
		return false;
	}

	function next(Iterator storage _it) returns (bool) {
		return _it.ix++ < _it.data.values.length;
	}

	function get(Iterator storage _it) returns (address) {
		return _it.data.values[_it.ix];
	}

	function find(Data storage _data, Iterator storage _it, address _value) {
	    begin(_data, _it);
		findNext(_data, _it, _value);
	}

	function findNext(Data storage _data, Iterator storage _it, address _value) {
		while (next(_it))
			if (get(_it) == _value)
				return;
	}

	function remove(Iterator storage _it) {
		remove(_it.data, _it.ix);
	}
}

/*
 * Contract map with string keys
 */
library Map {
	struct Data {
		mapping (address => bool)	 containAddress;
		mapping (bytes32 => bool)	 containKeyHash;
		mapping (bytes32 => address) addressOf; 
		Array.Data					 values;
		Array.Iterator               it;
	}

	function get(Data storage _data, string _key) returns (address) {
		return _data.addressOf[sha3(_key)];
	}

	function containKey(Data storage _data, string _key) returns (bool) {
		return _data.containKeyHash[sha3(_key)];
	}

	/*
	 * Set value for the key and return replaced address if exist
	 */
	function set(Data storage _data, string _key, address _value) returns (address) {
		var replaced = get(_data, _key);
		_data.containAddress[_value] = true;
		_data.containKeyHash[sha3(_key)] = true; 
		_data.addressOf[sha3(_key)]  = _value;
		Array.append(_data.values, _value);
		return replaced;
	}

	function remove(Data storage _data, string _key) returns (address) {
		var removedAddress = get(_data, _key);
		// Find and remove addres from values
		Array.find(_data.values, _data.it, removedAddress);
		Array.remove(_data.it);
        // Erase mapping information
		_data.addressOf[sha3(_key)] = 0;
		_data.containKeyHash[sha3(_key)] = false;
		// Check for the same address exist
		Array.find(_data.values, _data.it, removedAddress);
		_data.containAddress[removedAddress] = Array.end(_data.values, _data.it);
		return removedAddress;
	}
}
