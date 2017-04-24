pragma solidity ^0.4.9;

/**
 * @title Min/Max heap based market order price sorter
 */
contract MarketHeap {
    /**
     * @dev Mapping from order id to its price
     */
    mapping(uint256 => uint256) public priceOf;

    /**
     * @dev MaxHeap of asks
     */
    uint256[] public asks;

    /**
     * @dev Length of asks array
     */
    function asksLength() constant returns (uint256)
    { return asks.length; }

    /**
     * @dev Reverse map from order to ask index
     */
    mapping(uint256 => uint256) orderAskOf;

    /**
     * @dev MinHeap of bids
     */
    uint256[] public bids;

    /**
     * @dev Length of bids array
     */
    function bidsLength() constant returns (uint256)
    { return bids.length; }

    /**
     * @dev Reverse map from order to bid index
     */
    mapping(uint256 => uint256) orderBidOf;

    /**
     * @dev Put ask order
     * @param _id Order ident
     */
    function putAsk(uint256 _id) internal {
        orderAskOf[_id] = asks.length;
        asks.push(_id);

        var i = asks.length - 1;
        var parent = (i - 1) / 2;
        while (i > 0 && parent < i
                && priceOf[asks[i]] > priceOf[asks[parent]]) {
            var temp = asks[i];
            asks[i] = asks[parent];
            asks[parent] = temp;

            orderAskOf[asks[i]] = i;
            orderAskOf[asks[parent]] = parent;

            i = parent;
            parent = (i - 1) / 2;
        }
    }

    /**
     * @dev Remove ask order by index
     * @param _i Index of removed element, e.g. 0 is the head
     */
    function getAsk(uint256 _i) internal returns (uint256 id) {
        id = asks[_i];
        asks[_i] = asks[asks.length - 1];
        orderAskOf[asks[_i]] = _i;

        if (--asks.length == 0) return;

        // Heapity of MaxHeap
        var max = _i;
        for (;;) {
            var left  = 2 * _i + 1;
            var right = 2 * _i + 2;
            var parent = (_i - 1) / 2;

            var maxPrice = priceOf[asks[max]];

            if (parent < _i && priceOf[asks[parent]] < maxPrice) {
                // Price of parent should be bigger than item, other - swap
                max = parent;
            } else if (left < asks.length && priceOf[asks[left]] > maxPrice) {
                // Price of child should be lower than item, other - swap
                max = left;
            } else if (right < asks.length && priceOf[asks[right]] > maxPrice) {
                // Price of child should be lower than item, other - swap
                max = right;
            } else break;

            var temp  = asks[_i];
            asks[_i]  = asks[max];
            asks[max] = temp;

            orderAskOf[asks[_i]]  = _i;
            orderAskOf[asks[max]] = max;

            _i = max;
        }
    }

    /**
     * @dev Put bid order
     * @param _id Order ident
     */
    function putBid(uint256 _id) internal {
        orderBidOf[_id] = bids.length;
        bids.push(_id);

        var i = bids.length - 1;
        var parent = (i - 1) / 2;
        while (i > 0 && parent < i
                && priceOf[bids[i]] < priceOf[bids[parent]]) {
            var temp = bids[i];
            bids[i] = bids[parent];
            bids[parent] = temp;

            orderBidOf[bids[i]] = i;
            orderBidOf[bids[parent]] = parent;

            i = parent;
            parent = (i - 1) / 2;
        }
    }

    /**
     * @dev Remove bid order by index
     * @param _i Index of removed element, e.g. 0 is the head
     */
    function getBid(uint256 _i) internal returns (uint256 id) {
        id = bids[_i];
        bids[_i] = bids[bids.length - 1];
        orderBidOf[bids[_i]] = _i;

        if (--bids.length == 0) return;

        // Heapity of MinHeap
        var min = _i;
        for (;;) {
            var left  = 2 * _i + 1;
            var right = 2 * _i + 2;
            var parent = (_i - 1) / 2;

            var minPrice = priceOf[bids[min]];

            if (parent < _i && priceOf[bids[parent]] > minPrice) {
                // Price of parent should be lower than item, other - swap
                min = parent;
            } else if (left < bids.length && priceOf[bids[left]] < minPrice) {
                // Price of child should be bigger than item, other - swap
                min = left;
            } else if (right < bids.length && priceOf[bids[right]] < minPrice) {
                // Price of child should be bigger than item, other - swap
                min = right;
            } else break;

            var temp  = bids[_i];
            bids[_i]  = bids[min];
            bids[min] = temp;

            orderBidOf[bids[_i]]  = _i;
            orderBidOf[bids[min]] = min;

            _i = min;
        }
    }
}
