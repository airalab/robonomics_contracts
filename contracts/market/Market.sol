pragma solidity ^0.4.4;
//import './MarketRegulator.sol';
import 'common/Object.sol';
import 'token/ERC20.sol';

/**
 * @title Token-based market
 */
contract Market is Object {
    // Market name
    string public name;

    // Base token
    ERC20 public base;

    // Quote token
    ERC20 public quote;

    // Price precision
    uint public decimals;

    /**
     * @dev Market constructor
     * @param _name Market name
     * @param _base Makret base token
     * @param _quote Market quote token
     * @param _decimals Price precision in decimal point
     */
    function Market(string _name, address _base, address _quote, uint _decimals) {
        name     = _name;
        base     = ERC20(_base);
        quote    = ERC20(_quote);
        decimals = _decimals;
    }

    // Optional regulator
    //MarketRegulator public regulator;

    //function setRegulator(MakretRegulator _regulator) onlyOwner
    //{ regulator = _regulator; }

    // MaxHeap of current asks
    uint[] public asks;
    // Reverse from order to ask index
    mapping(uint => uint) public orderAskOf;

    function asksLen() constant returns (uint)
    { return asks.length; }

    // MinHeap of current bids
    uint[] public bids;
    // Reverse from order to bid index
    mapping(uint => uint) public orderBidOf;
    
    function bidsLen() constant returns (uint)
    { return bids.length; }

    function insertAsk(uint _id) internal {
        asks.push(_id);

        uint i = asks.length - 1;
        uint parent = (i - 1) / 2;
        while (i > 0 && orders[asks[i]].price > orders[asks[parent]].price) {
            uint temp = asks[i];
            asks[i] = asks[parent];
            asks[parent] = temp;

            orderAskOf[asks[i]] = i;
            orderAskOf[asks[parent]] = parent;

            i = parent;
            parent = (i - 1) / 2;
        }
    }

    function getAsk(uint _i) internal returns (uint id) {
        id = asks[_i];
        asks[_i] = asks[asks.length - 1];
        orderAskOf[asks[_i]] = _i;
        --asks.length;
        heapityAsk(_i);
    }

    function heapityAsk(uint _i) internal {
        for (;;) {
            uint left  = 2 * _i + 1;
            uint right = 2 * _i + 2;
            uint largest = _i;

            if (left < asks.length
                && orders[asks[left]].price > orders[asks[largest]].price) {
                    largest = left;
            } else if (right < asks.length
                && orders[asks[right]].price > orders[asks[largest]].price) {
                    largest = right;
            } else break;

            uint temp = asks[_i];
            asks[_i] = asks[largest];
            asks[largest] = temp;

            orderAskOf[asks[_i]] = _i;
            orderAskOf[asks[largest]] = largest;

            _i = largest;
        }
    }

    function insertBid(uint _id) internal {
        bids.push(_id);

        uint i = bids.length - 1;
        uint parent = (i - 1) / 2;
        while (i > 0 && orders[bids[i]].price < orders[bids[parent]].price) {
            uint temp = bids[i];
            bids[i] = bids[parent];
            bids[parent] = temp;

            orderBidOf[bids[i]] = i;
            orderBidOf[bids[parent]] = parent;

            i = parent;
            parent = (i - 1) / 2;
        }
    }

    function getBid(uint _i) internal returns (uint id) {
        id = bids[_i];
        bids[_i] = bids[bids.length - 1];
        orderBidOf[bids[_i]] = _i;
        --bids.length;
        heapityBid(_i);
    }

    function heapityBid(uint _i) internal {
        for (;;) {
            uint left  = 2 * _i + 1;
            uint right = 2 * _i + 2;
            uint smallest = _i;

            if (left < asks.length
                && orders[asks[left]].price < orders[asks[smallest]].price) {
                    smallest = left;
            } else if (right < asks.length
                && orders[asks[right]].price < orders[asks[smallest]].price) {
                    smallest = right;
            } else break;

            uint temp = asks[_i];
            asks[_i] = asks[smallest];
            asks[smallest] = temp;

            orderBidOf[bids[_i]] = _i;
            orderBidOf[bids[smallest]] = smallest;

            _i = smallest;
        }
    }

    // The order definition
    enum OrderKind { Sell, Buy }
    struct Order {
        // Order kind: buy or sell
        OrderKind kind;

        // Sender agent address
        address   agent;

        // Base unit price in quote
        uint      price;

        // Base unit value
        uint      value;

        // Order start value
        uint      startValue;

        // Timestamp
        uint      stamp;
    }

    // Orders of all time
    Order[] public orders;

    /**
     * @dev Event emitted when order is opened
     */
    event OrderOpened(uint indexed order, address indexed agent);

    /**
     * @dev Event emitted when order is closed
     */
    event OrderClosed(uint indexed order);
 
    /**
     * @dev Open limit order
     * @param _kind Order kind: sell or buy
     * @param _value Base unit value
     * @param _price Base unit price (multiplied by 10^decimals)
     */
    function orderLimit(OrderKind _kind, uint _value, uint _price) returns (bool) {
        var id = orders.length;

        if (_kind == OrderKind.Sell) {

            if (!base.transferFrom(msg.sender, this, _value)) throw;

            orders.push(Order(OrderKind.Sell, msg.sender, _price, _value, _value, now));
            insertBid(id);

        } else if (_kind == OrderKind.Buy) {

            var quote_value = _price * _value / (10 ** decimals);
            if (!quote.transferFrom(msg.sender, this, quote_value)) throw;

            orders.push(Order(OrderKind.Buy, msg.sender, _price, _value, _value, now));
            insertAsk(id);

        } else throw;

        OrderOpened(id, msg.sender);
        return true;
    }

    function marketSell(address _agent, uint _value) internal returns (bool) {
        uint quote_value = 0;

        while (_value > 0) {
            // Check of empty bids
            if (asks.length == 0) throw;

            // Get asks head
            var o = orders[asks[0]];

            if (o.value > _value) {
                // Makret top is large
                quote_value = o.price * _value / (10 ** decimals);
                if (!quote.transfer(msg.sender, quote_value)) throw;
                if (!base.transferFrom(msg.sender, o.agent, o.value)) throw;

                o.value -= _value;
                break;
            } else {
                // Market top is small
                quote_value = o.price * o.value / (10 ** decimals);
                if (!quote.transfer(msg.sender, quote_value)) throw;
                if (!base.transferFrom(msg.sender, o.agent, o.value)) throw;

                _value -= o.value;
                OrderClosed(getAsk(0));
            }
        }
        return true;
    }

    function marketBuy(address _agent, uint _value) internal returns (bool) {
        uint quote_value = 0;

        while (_value > 0) {
            // Check of empty bids
            if (bids.length == 0) throw;

            // Get bids head
            var o = orders[bids[0]];

            if (o.value > _value) {
                // Makret top is large
                quote_value = o.price * _value / (10 ** decimals);
                if (!quote.transferFrom(msg.sender, o.agent, quote_value)) throw;
                if (!base.transfer(msg.sender, _value)) throw;

                o.value -= _value;
                break;
            } else {
                // Market top is small
                quote_value = o.price * o.value / (10 ** decimals);
                if (!quote.transferFrom(msg.sender, o.agent, quote_value)) throw;
                if (!base.transfer(msg.sender, o.value)) throw;

                _value -= o.value;
                OrderClosed(getBid(0));
            }
        }

        return true;
    }

    /**
     * @dev Open market order
     * @param _kind Order kind: sell or buy
     * @param _value Base unit value
     */
    function orderMarket(OrderKind _kind, uint _value) returns (bool) {
        if (_kind == OrderKind.Sell) {

            if (!marketSell(msg.sender, _value)) throw;

        } else if (_kind == OrderKind.Buy) {

            if (!marketBuy(msg.sender, _value)) throw;

        } else throw;

        return true;
    }
}
