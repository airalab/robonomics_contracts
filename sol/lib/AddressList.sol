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

    function first(Data storage _data) constant returns (address)
    { return _data.head; }

    function last(Data storage _data) constant returns (address)
    { return _data.tail; }

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
    function append(Data storage _data, address _item)
    { append(_data, _item, _data.tail); }

    /**
     * @dev Append element to end of element
     * @param _data is list storage ref
     * @param _item is a new list element  
     * @param _to is a item element before new 
     */
    function append(Data storage _data, address _item, address _to) {
        // Unable to contain double element
        if (_data.isContain[_item]) throw;

        // Empty list
        if (_data.head == 0) {
            _data.head = _data.tail = _item;
        } else {
            var nextTo = _data.nextOf[_to];
            if (nextTo != 0) {
                _data.prevOf[nextTo] = _item;
            } else {
                _data.tail = _item;
            }

            _data.nextOf[_to]    = _item;
            _data.prevOf[_item]  = _to;
            _data.nextOf[_item]  = nextTo;
        }
        _data.isContain[_item] = true;
    }
 
    /**
     * @dev Prepend element to begin of list
     * @param _data is list storage ref
     * @param _item is a new list element  
     */
    function prepend(Data storage _data, address _item)
    { prepend(_data, _item, _data.head); }

    /**
     * @dev Prepend element to element of list
     * @param _data is list storage ref
     * @param _item is a new list element  
     * @param _to is a item element before new 
     */
    function prepend(Data storage _data, address _item, address _to) {
        // Unable to contain double element
        if (_data.isContain[_item]) throw;

        // Empty list
        if (_data.head == 0) {
            _data.head = _data.tail = _item;
        } else {
            var prevTo = _data.prevOf[_to];
            if (prevTo != 0) {
                _data.nextOf[prevTo] = _item;
            } else {
                _data.head = _item;
            }

            _data.prevOf[_item]  = prevTo;
            _data.nextOf[_item]  = _to;
            _data.prevOf[_to]    = _item;
        }
        _data.isContain[_item] = true;
    }

    /**
     * @dev Remove element from list
     * @param _data is list storage ref
     * @param _item is a removed list element
     */
    function remove(Data storage _data, address _item) {
        if (_data.isContain[_item]) {
            var elemPrev = _data.prevOf[_item];
            var elemNext = _data.nextOf[_item];

            if (elemPrev != 0) {
                _data.nextOf[elemPrev] = elemNext;
            } else {
                _data.head = elemNext;
            }

            if (elemNext != 0) {
                _data.prevOf[elemNext] = elemPrev;
            } else {
                _data.tail = elemPrev;
            }

            _data.isContain[_item] = false;
        }
    }

    /**
     * @dev Replace element on list
     * @param _data is list storage ref
     * @param _from is old element
     * @param _to is a new element
     */
    function replace(Data storage _data, address _from, address _to) {
        if (_data.isContain[_from]) {
            var elemPrev = _data.prevOf[_from];
            var elemNext = _data.nextOf[_from];

            if (elemPrev != 0) {
                _data.nextOf[elemPrev] = _to;
            } else {
                _data.head = _to;
            }
            
            if (elemNext != 0) {
                _data.prevOf[elemNext] = _to;
            } else {
                _data.tail = _to;
            }

            _data.prevOf[_to] = elemPrev;
            _data.nextOf[_to] = elemNext;
            _data.isContain[_from] = false;
        }
    }

    /**
     * @dev Swap two elements of list
     * @param _data is list storage ref
     * @param _a is a first element
     * @param _b is a second element
     */
    function swap(Data storage _data, address _a, address _b) {
        if (_data.isContain[_a] && _data.isContain[_b]) {
            var prevA = _data.prevOf[_a];
            var prevB = _data.prevOf[_b];
            var nextA = _data.nextOf[_a];
            var nextB = _data.nextOf[_b];
            // Insert A
            _data.nextOf[_a] = nextB;
            _data.prevOf[_a] = prevB;

            if (prevB != 0) {
                _data.nextOf[prevB] = _a;
            } else {
                _data.head = _a;
            }

            if (nextB != 0) {
                _data.prevOf[nextB] = _a;
            } else {
                _data.tail = _a;
            }
            // Inser B
            _data.nextOf[_b]    = nextA;
            _data.prevOf[_b]    = prevA;

            if (prevA != 0) {
                _data.nextOf[prevA] = _b;
            } else {
                _data.head = _b;
            }

            if (nextA != 0) {
                _data.prevOf[nextA] = _b;
            } else {
                _data.tail = _b;
            }
        }
    }
}
