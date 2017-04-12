pragma solidity ^0.4.4;

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
        asks.push(_id);

        var i = asks.length - 1;
        var parent = (i - 1) / 2;
        while (i > 0 && priceOf[asks[i]] > priceOf[asks[parent]]) {
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
        --asks.length;

        // Heapity of MaxHeap
        for (;;) {
            var left  = 2 * _i + 1;
            var right = 2 * _i + 2;

            var max = _i;
            var maxPrice = priceOf[asks[max]];

            if (left < asks.length && priceOf[asks[left]] > maxPrice) {
                max = left;
            } else if (right < asks.length && priceOf[asks[right]] > maxPrice) {
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
        bids.push(_id);

        var i = bids.length - 1;
        var parent = (i - 1) / 2;
        while (i > 0 && priceOf[bids[i]] < priceOf[bids[parent]]) {
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
        --bids.length;

        // Heapity of MinHeap
        for (;;) {
            var left  = 2 * _i + 1;
            var right = 2 * _i + 2;

            var min      = _i;
            var minPrice = priceOf[bids[_i]];

            if (left < bids.length && priceOf[bids[left]] < minPrice) {
                min = left;
            } else if (right < bids.length && priceOf[bids[right]] < minPrice) {
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
