pragma solidity ^0.4.4;
import 'common/Object.sol';
import 'token/ERC20.sol';
import './MarketHeap.sol';

/**
 * @title Token-based market
 */
contract Market is Object, MarketHeap {
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

    // The order definition
    enum OrderKind { Sell, Buy }
    struct Order {
        // Order kind: buy or sell
        OrderKind kind;

        // Sender agent address
        address   agent;

        // Base unit value
        uint256   value;

        // Order start value
        uint256   startValue;

        // Timestamp
        uint256   stamp;
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

            orders.push(Order(OrderKind.Sell, msg.sender, _value, _value, now));
            priceOf[orders.length-1] = _price;
            putBid(id);

        } else if (_kind == OrderKind.Buy) {

            var quote_value = _price * _value / (10 ** decimals);
            if (!quote.transferFrom(msg.sender, this, quote_value)) throw;

            orders.push(Order(OrderKind.Buy, msg.sender, _value, _value, now));
            priceOf[orders.length-1] = _price;
            putAsk(id);

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
            var id = asks[0];
            var o = orders[id];

            if (o.value > _value) {
                // Makret top is large
                quote_value = priceOf[id] * _value / (10 ** decimals);
                if (!quote.transfer(msg.sender, quote_value)) throw;
                if (!base.transferFrom(msg.sender, o.agent, o.value)) throw;

                o.value -= _value;
                break;
            } else {
                // Market top is small
                quote_value = priceOf[id] * o.value / (10 ** decimals);
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
            var id = bids[0];
            var o = orders[id];

            if (o.value > _value) {
                // Makret top is large
                quote_value = priceOf[id] * _value / (10 ** decimals);
                if (!quote.transferFrom(msg.sender, o.agent, quote_value)) throw;
                if (!base.transfer(msg.sender, _value)) throw;

                o.value -= _value;
                break;
            } else {
                // Market top is small
                quote_value = priceOf[id] * o.value / (10 ** decimals);
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
