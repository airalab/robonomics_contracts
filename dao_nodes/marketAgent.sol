import "agent";
import "user";
import "di";
import "market";
import "pie";

contract agentMarket {
    address public creator;
    address public agentInfoAddr;
    agent Agent;
    market Market;
	
	Hold[] public holds;
	struct Hold {
        address agent;
        address asset;
        uint price;
        uint total;
        bool active;
        bool deal;
        bool sell;
	}
    uint public countHolds;
	
    struct Order {
        address assetAddr;
        uint orderId;
        uint price;
        uint total;
        uint min;
        uint step;
        uint orderType;
        bool active;
    }
    Order[] public orders;
    uint public countOrders;

    function agentMarket(address _agentAddr, address _agentInfoAddr, address _marketAddr) {
        creator = msg.sender;
		agentInfoAddr = _agentInfoAddr;
		Agent = agent(_agentAddr);
        Market = market(_marketAddr);
    }
    
    function addSell(address _assetAddr, uint _total, uint _unitPrice, uint _min, uint _step) returns(uint) {
		if (Agent.typeAgent() == 2) {
			_unitPrice = pie(_assetAddr).faceValue();
		}
		uint orderId = Market.addSell(_assetAddr, _total, _unitPrice, _min, _step);
		uint id = orders.length++;
        Order o = orders[id];
        o.assetAddr = _assetAddr;
        o.orderId = orderId;
        o.price = _unitPrice;
        o.total = _total;
        o.min = _min;
        o.step = _step;
        o.orderType = 1;
        o.active = true;
		countOrders++;
		return id;
    }

    function removeSell(address _assetAddr, uint _orderID) returns(bool) {
		uint i;
		for (i = 0; i <= orders.length; i++) {
			if (orders[i].orderType == 1 && orders[i].assetAddr == _assetAddr && orders[i].orderId == _orderID) {
				orders[i].active = false;
			}
		}
        return Market.removeSell(_assetAddr, _orderID);
    }

    function addBuy(address _assetAddr, uint _total, uint _unitPrice, uint _min, uint _step) returns(uint) {
		if (Agent.typeAgent() == 2) {
			_unitPrice = pie(_assetAddr).faceValue();
		}
        uint orderId = Market.addBuy(_assetAddr, _total, _unitPrice, _min, _step);
		uint id = orders.length++;
        Order o = orders[id];
        o.assetAddr = _assetAddr;
        o.orderId = orderId;
        o.price = _unitPrice;
        o.total = _total;
        o.min = _min;
        o.step = _step;
        o.orderType = 2;
        o.active = true;
		countOrders++;
		return orderId;
    }

    function removeBuy(address _assetAddr, uint _orderID) returns(bool) {
		uint i;
		for (i = 0; i <= orders.length; i++) {
			if (orders[i].orderType == 2 && orders[i].assetAddr == _assetAddr && orders[i].orderId == _orderID) {
				orders[i].active = false;
			}
		}
        return Market.removeBuy(_assetAddr, _orderID);
    }

    function setHold(uint _orderID, address _agent, address _asset, uint _total) returns(uint) {
		address myAddress = this;
		if (Market.getSellOwner(_asset, _orderID) != myAddress) {
			return 0;
		}
		if (Agent.getBalance(_asset) < _total) {
            return 0;
        }	
        uint id = holds.length++;
        Hold h = holds[id];
        h.agent = _agent;
        h.asset = _asset;
        h.price = Market.getSellPrice(_asset, _orderID);
        h.total = _total;
        h.active = true;
        h.deal = false;
        h.sell = true;
        Market.downSell(_asset, _orderID, _total);
		countHolds++;
		agentMarket(_agent).setHoldBuy(_orderID, this, _asset, _total);
        return id;
    }

    function setHoldBuy(uint _orderID, address _agent, address _asset, uint _total) returns(uint) {
        uint id = holds.length++;
        Hold h = holds[id];
        h.agent = _agent;
        h.asset = _asset;
        h.price = Market.getSellPrice(_asset, _orderID);
        h.total = _total;
        h.active = true;
        h.deal = false;
        h.sell = false;
		countHolds++;
        return id;
    }

    function removeHold(uint _id) returns(bool) {
        Hold h = holds[_id];
        if (h.active == true) {
            h.active = false;
            return true;
        }
        return false;
    }

    function deal(uint _id) {
        Hold h = holds[_id];
        if (h.active == true && h.deal == false && h.sell == true) {
            h.active = false;
            h.deal = true;
			
			Agent.transfer(h.asset, agentMarket(h.agent).creator(), h.total);
        }
    }
}
