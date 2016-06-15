import './AddressList.sol';

/**
 * @dev Iterable by index (string => address) mapping structure
 *      with reverse resolve and fast element remove
 */
library AddressMap {
    struct Data {
        mapping(bytes32 => address) valueOf;
        mapping(address => string)  keyOf;
        AddressList.Data            items;
    }

    using AddressList for AddressList.Data;

    /**
     * @dev Get element by name
     * @param _data is an map storage ref
     * @param _key is a item key
     * @return item value
     */
    function get(Data storage _data, string _key) constant returns (address)
    { return _data.valueOf[sha3(_key)]; }

    /** Get key of element
     * @param _data is an map storage ref
     * @param _item is a item
     * @return item key
     */
    function getKey(Data storage _data, address _item) constant returns (string)
    { return _data.keyOf[_item]; }

    /**
     * @dev Set element value for given key
     * @param _data is an map storage ref
     * @param _key is a item key
     * @param _value is a item value
     * @notice by design you can't set different keys with same value
     */
    function set(Data storage _data, string _key, address _value) {
        var replaced = get(_data, _key);
        if (replaced != 0)
            _data.items.replace(replaced, _value);
        else
            _data.items.append(_value);
        _data.valueOf[sha3(_key)] = _value;
        _data.keyOf[_value]       = _key;
    }

    /**
     * @dev Remove item from map by key
     * @param _data is an map storage ref
     * @param _key is and item key
     */
    function remove(Data storage _data, string _key) {
        var value = get(_data, _key);
        _data.items.remove(value);
        _data.valueOf[sha3(_key)] = 0;
        _data.keyOf[value]        = "";
    }
}
