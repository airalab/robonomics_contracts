pragma solidity ^0.4.18;
//import 'dao/Liability.sol';
import 'common/Object.sol';
import 'token/ERC20.sol';
import './MarketHeap.sol';

library CreatorLiability {
    function create(address, address, address, uint256) public
             returns (Liability);
}

/**
 * @title Liability marketplace
 */
contract LiabilityMarket is Object, MarketHeap {
    // Market name
    string public name;

    // Token
    ERC20 constant token = ERC20(0);

    /**
     * @dev Market constructor
     * @param _name Market name
     */
    function LiabilityMarket(string _name) public {
        name = _name;
        // Put empty oreder with zero index
        orders[orders.length++].closed = true;
    }

    struct Order {
        address[] beneficiary;
        address[] promisee;
        address   promisor;
        bool      closed;
    }

    Order[] orders;

    /**
     * @dev Get order by index
     * @param _i Order index
     * @return Order fields
     */
    function getOrder(uint256 _i) public view returns (address[], address[], address, bool) {
        var o = orders[_i];
        return (o.beneficiary, o.promisee, o.promisor, o.closed);
    }

    /**
     * @dev Get account order ids
     */
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
     * @param _beneficiary Liability beneficiary
     * @param _promisee Liability promisee
     * @param _price Liability price
     * @notice Sender is promisee of liability
     */
    function limitSell(address _beneficiary, address _promisee, uint256 _price) public {
        var id = orders.length++;

        // Store price
        priceOf[id] = _price;
        // Append bid
        putBid(id);
        // Store template
        orders[id].beneficiary.push(_beneficiary);
        orders[id].promisee.push(_promisee); 

        ordersOf[msg.sender].push(id);
        OpenBidOrder(id);
    }

    /**
     * @dev Make a limit order to buy liability
     * @param _price Liability price
     * @notice Sender is promisor of liability
     */
    function limitBuy(uint256 _price) public {
        var id = orders.length++;

        // Store price
        priceOf[id] = _price;
        // Append ask
        putAsk(id);
        // Store template
        orders[id].promisor = msg.sender;

        // Lock tokens
        require (token.transferFrom(msg.sender, this, _price));

        ordersOf[msg.sender].push(id);
        OpenAskOrder(id);
    }

    /**
     * @dev Sell liability
     * @param _id Order index 
     * @param _beneficiary Benificiary candidate
     * @param _promisee Promisee candidate
     */
    function sellAt(uint256 _id, address _beneficiary, address _promisee) public {
        var order = orders[_id];
        if (_id >= orders.length || order.closed) revert();

        order.beneficiary.push(_beneficiary);
        order.promisee.push(_promisee);

        AskOrderCandidates(_id, _beneficiary, _promisee);
    }

    /**
     * @dev Confirm liability sell
     * @param _id Order index 
     * @param _candidates Confirmed candidates
     */
    function sellConfirm(uint256 _id, uint256 _candidates) public {
        var o = orders[_id];
        if (_id >= orders.length || o.closed) revert();

        getAsk(orderAskOf[_id]);

        require (o.promisor == msg.sender);
        require (o.beneficiary[_candidates] != 0); 

        require (runLiability(o.beneficiary[_candidates],
                          o.promisee[_candidates],
                          o.promisor,
                          priceOf[_id]));

        o.closed = true;
        CloseAskOrder(_id);
    }

    /**
     * @dev Buy liability
     * @param _id Order index 
     */
    function buyAt(uint256 _id) public {
        var o = orders[_id];
        if (_id >= orders.length || o.closed) revert();

        getBid(orderBidOf[_id]);
        o.promisor = msg.sender;

        require (token.transferFrom(msg.sender, this, priceOf[_id]));

        require (runLiability(o.beneficiary[0],
                          o.promisee[0],
                          o.promisor,
                          priceOf[_id]));

        o.closed = true;
        CloseBidOrder(_id);
    }

    function runLiability(
        address _beneficiary,
        address _promisee,
        address _promisor,
        uint256 _price
    ) internal returns (bool) {
        var l = CreatorLiability.create(_promisor, _promisee, token, _price);
        l.setOwner(_beneficiary);

        require (token.transfer(l, _price));
        require (l.call.value(l.gasbase() * tx.gasprice)());

        NewLiability(l);
        return true;
    }

    function () public payable {}
}
