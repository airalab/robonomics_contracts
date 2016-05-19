/**
 * @dev Double linked list with address items
 */
library AddressList {
    struct Data {
        address head;
        address tail;
        mapping(address => bool)    isContain;
        mapping(address => address) nextOf;
        mapping(address => address) prevOf;
    }

    /**
     * @dev Chec list for element
     * @param _data is list storage ref
     * @param _item is an element
     * @return `true` when element in list
     */
    function contains(Data storage _data, address _item) constant returns (bool)
    { return _data.isContain[_item]; }

    /**
     * @dev Next element of list
     * @param _data is list storage ref
     * @param _item is current element of list
     * @return next elemen of list
     */
    function next(Data storage _data, address _item) constant returns (address)
    { return _data.nextOf[_item]; }

    /**
     * @dev Previous element of list
     * @param _data is list storage ref
     * @param _item is current element of list
     * @return previous element of list 
     */
    function prev(Data storage _data, address _item) constant returns (address)
    { return _data.prevOf[_item]; }

    /**
     * @dev Append element to end of list
     * @param _data is list storage ref
     * @param _item is a new list element  
     */
    function append(Data storage _data, address _item) {
        // Empty list
        if (_data.tail == 0) {
            _data.head = _data.tail = _item;
        } else {
            _data.nextOf[_data.tail]  = _item;
            _data.prevOf[_item]       = _data.tail;
            _data.tail                = _item;
        }
        _data.isContain[_item] = true;
    }

    /**
     * @dev Remove element from list
     * @param _data is list storage ref
     * @param _item is a removed list element
     */
    function remove(Data storage _data, address _item) {
        var elemPrev = _data.prevOf[_item];
        var elemNext = _data.nextOf[_item];
        _data.nextOf[elemPrev] = elemNext;
        _data.prevOf[elemNext] = elemPrev;
        _data.isContain[_item] = false;
    }

    /**
     * @dev Replace element on list
     * @param _data is list storage ref
     * @param _from is old element
     * @param _to is a new element
     */
    function replace(Data storage _data, address _from, address _to) {
        var elemPrev = _data.prevOf[_from];
        var elemNext = _data.nextOf[_from];
        _data.nextOf[elemPrev] = _to;
        _data.prevOf[elemNext] = _to;
        _data.isContain[_from] = false;
    }
}
