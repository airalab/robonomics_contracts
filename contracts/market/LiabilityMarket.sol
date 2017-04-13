pragma solidity ^0.4.4;
import 'dao/Liability.sol';
import 'common/Object.sol';
import 'token/ERC20.sol';
import './MarketHeap.sol';

/**
 * @title Liability marketplace
 */
contract LiabilityMarket is Object, MarketHeap {
    // Market name
    string public name;

    // Market token
    ERC20 public token;

    /**
     * @dev Market constructor
     * @param _name Market name
     * @param _token Makret token
     */
    function LiabilityMarket(string _name, address _token) {
        name  = _name;
        token = ERC20(_token);
    }

    struct Order {
        address[] beneficiary;
        address[] promisee;
        address   promisor;
        bool      closed;
    }

    Order[] public orders;

    mapping(address => uint[]) public ordersOf;

    event OpenAskOrder(uint256 indexed order);
    event OpenBidOrder(uint256 indexed order);
    event CloseAskOrder(uint256 indexed order);
    event CloseBidOrder(uint256 indexed order);

    event AskOrderCandidates(uint256 indexed order,
                             address indexed beneficiary, 
                             address indexed promisee);

    event NewLiability(address indexed liability);

    /**
     * @dev Make a limit order to sell liability
     * @param _promisee Liability beneficiary
     * @param _price Liability price
     * @notice Sender is promisee of liability
     */
    function limitSell(address _promisee, uint256 _price) {
        var id = orders.length++;

        // Store price
        priceOf[id] = _price;
        // Append bid
        putBid(id);
        // Store template
        orders[id].beneficiary.push(msg.sender);
        orders[id].promisee.push(_promisee); 

        ordersOf[msg.sender].push(id);
        OpenBidOrder(id);
    }

    /**
     * @dev Make a limit order to buy liability
     * @param _price Liability price
     * @notice Sender is promisor of liability
     */
    function limitBuy(uint256 _price) {
        var id = orders.length++;

        // Store price
        priceOf[id] = _price;
        // Append ask
        putAsk(id);
        // Store template
        orders[id].promisor = msg.sender;

        // Lock tokens
        if (!token.transferFrom(msg.sender, this, _price))
            throw;

        ordersOf[msg.sender].push(id);
        OpenAskOrder(id);
    }

    /**
     * @dev Sell liability
     * @param _id Order index 
     * @param _promisee Promisee candidate
     */
    function sellAt(uint256 _id, address _promisee) {
        var order = orders[_id];
        if (_id >= orders.length || order.closed) throw;

        order.beneficiary.push(msg.sender);
        order.promisee.push(_promisee);

        AskOrderCandidates(_id, msg.sender, _promisee);
    }

    /**
     * @dev Confirm liability sell
     * @param _id Order index 
     * @param _candidates Confirmed candidates
     */
    function sellConfirm(uint256 _id, uint256 _candidates) {
        var o = orders[_id];
        if (_id >= orders.length || o.closed) throw;

        getAsk(orderAskOf[_id]);

        if (o.promisor != msg.sender) throw;
        if (o.beneficiary[_candidates] == 0) throw; 

        if (!runLiability(o.beneficiary[_candidates],
                          o.promisee[_candidates],
                          o.promisor,
                          priceOf[_id])) throw;

        CloseAskOrder(_id);
    }

    /**
     * @dev Buy liability
     * @param _id Order index 
     */
    function buyAt(uint256 _id) {
        var o = orders[_id];
        if (_id >= orders.length || o.closed) throw;

        getBid(orderBidOf[_id]);
        o.promisor = msg.sender;

        if (!token.transferFrom(msg.sender, this, priceOf[_id]))
            throw;

        if (!runLiability(o.beneficiary[0],
                          o.promisee[0],
                          o.promisor,
                          priceOf[_id])) throw;

        CloseBidOrder(_id);
    }

    function runLiability(
        address _beneficiary,
        address _promisee,
        address _promisor,
        uint256 _price
    ) internal returns (bool) {
        var l = new Liability(_promisor, _promisee, token, _price);
        l.setOwner(_beneficiary);

        if (!token.transfer(l, _price)) throw;
        if (!l.call.value(l.gasbase() * tx.gasprice)()) throw;

        NewLiability(l);
        return true;
    }

    function () payable {}
}
