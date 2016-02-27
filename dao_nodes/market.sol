contract market {
    address creator;
    token Token;
    etherToken EtherToken;

    struct Order {
        uint orderID;
        address owner;
        uint total;
        uint unitPrice;
        uint min;
        uint step;
        bool active;
    }

    struct SaleAssetList {
        address assetAddr;
        Order[] sellOrderList;
    }

    struct BuyAssetList {
        address assetAddr;
        Order[] buyOrderList;
    }

    SaleAssetList[] public sellAssetList;
    mapping (address => bool) public sellExistOf;
    mapping (address => uint) public sellDataOf;
    mapping (address => uint) public sellCountAsset;

    BuyAssetList[] public buyAssetList;
    mapping (address => bool) public buyExistOf;
    mapping (address => uint) public buyDataOf;
    mapping (address => uint) public buyCountAsset;

    function market(address _etherTokenAddr) {
        creator = msg.sender;
        EtherToken = etherToken(_etherTokenAddr);
    }

    function addSell(address _assetAddr, uint _total, uint _unitPrice, uint _min, uint _step) returns(uint sellID) {
        uint assetID;
        if (sellExistOf[_assetAddr]) {
            assetID = sellDataOf[_assetAddr];
            SaleAssetList sellAssetOrders = sellAssetList[assetID];
        } else {
            assetID = sellAssetList.length++;
			sellDataOf[_assetAddr] = assetID;
            sellExistOf[_assetAddr] = true;
            sellAssetOrders = sellAssetList[assetID];
            sellAssetOrders.assetAddr = _assetAddr;
        }
        sellID = sellAssetOrders.sellOrderList.length++;

        Order order = sellAssetOrders.sellOrderList[sellID];
        order.orderID = sellID;
        order.owner = msg.sender;
        order.total = _total;
        order.unitPrice = _unitPrice;
        order.min = _min;
        order.step = _step;
        order.active = true;
		
        sellCountAsset[_assetAddr] = sellID;

        return sellID;
    }

    function addBuy(address _assetAddr, uint _total, uint _unitPrice, uint _min, uint _step) returns(uint buyID) {
        uint assetID;
        if (buyExistOf[_assetAddr]) {
            assetID = buyDataOf[_assetAddr];
            BuyAssetList buyAssetOrders = buyAssetList[assetID];
        } else {
            assetID = buyAssetList.length++;
			buyDataOf[_assetAddr] = assetID;
            buyExistOf[_assetAddr] = true;
            buyAssetOrders = buyAssetList[assetID];
            buyAssetOrders.assetAddr = _assetAddr;
        }
        buyID = buyAssetOrders.buyOrderList.length++;

        Order order = buyAssetOrders.buyOrderList[buyID];
        order.orderID = buyID;
        order.owner = msg.sender;
        order.total = _total;
        order.unitPrice = _unitPrice;
        order.min = _min;
        order.step = _step;
        order.active = true;
		
        buyCountAsset[_assetAddr] = buyID;

        return buyID;
    }

    function removeSell(address _assetAddr, uint _orderID) returns(bool) {
        if (sellExistOf[_assetAddr]) {
            uint assetID = sellDataOf[_assetAddr];
            Order order = sellAssetList[assetID].sellOrderList[_orderID];
            if (order.owner == msg.sender) {
                order.active = false;
                return true;
            }
        }
        return false;
    }

    function removeBuy(address _assetAddr, uint _orderID) returns(bool) {
        if (buyExistOf[_assetAddr]) {
            uint assetID = buyDataOf[_assetAddr];
            Order order = buyAssetList[assetID].buyOrderList[_orderID];
            if (order.owner == msg.sender) {
                order.active = false;
                return true;
            }
        }
        return false;
    }

    function downSell(address _assetAddr, uint _orderID, uint _total) {
        if (sellExistOf[_assetAddr]) {
            uint assetID = sellDataOf[_assetAddr];
            Order order = sellAssetList[assetID].sellOrderList[_orderID];
            order.total = order.total - _total;
            if (order.total == 0) {
                order.active = false;
            }
        }
    }

    function downBuy(address _assetAddr, uint _orderID, uint _total) {
        if (sellExistOf[_assetAddr]) {
            uint assetID = buyDataOf[_assetAddr];
            Order order = buyAssetList[assetID].buyOrderList[_orderID];
            order.total = order.total - _total;
            if (order.total == 0) {
                order.active = false;
            }
        }
    }

    function getSell(address _assetAddr, uint _orderID) returns(address owner, uint total, uint unitPrice, uint min, uint step, bool active) {
        if (sellExistOf[_assetAddr]) {
            uint assetID = sellDataOf[_assetAddr];
            Order order = sellAssetList[assetID].sellOrderList[_orderID];
            return (order.owner, order.total, order.unitPrice, order.min, order.step, order.active);
        }
    }

    function getBuy(address _assetAddr, uint _orderID) returns(address owner, uint total, uint unitPrice, uint min, uint step, bool active) {
        if (buyExistOf[_assetAddr]) {
            uint assetID = buyDataOf[_assetAddr];
            Order order = buyAssetList[assetID].buyOrderList[_orderID];
            return (order.owner, order.total, order.unitPrice, order.min, order.step, order.active);
        }
    }

    function getSellOwner(address _assetAddr, uint _orderID) returns(address) {
        if (sellExistOf[_assetAddr]) {
            uint assetID = sellDataOf[_assetAddr];
            Order order = sellAssetList[assetID].sellOrderList[_orderID];
            return order.owner;
        }
    }

    function getBuyOwner(address _assetAddr, uint _orderID) returns(address) {
        if (buyExistOf[_assetAddr]) {
            uint assetID = buyDataOf[_assetAddr];
            Order order = buyAssetList[assetID].buyOrderList[_orderID];
            return order.owner;
        }
    }

    function getSellPrice(address _assetAddr, uint _orderID) returns(uint) {
        if (sellExistOf[_assetAddr]) {
            uint assetID = sellDataOf[_assetAddr];
            Order order = sellAssetList[assetID].sellOrderList[_orderID];
            return order.unitPrice;
        }
    }

    function getBuyPrice(address _assetAddr, uint _orderID) returns(uint) {
        if (buyExistOf[_assetAddr]) {
            uint assetID = buyDataOf[_assetAddr];
            Order order = buyAssetList[assetID].buyOrderList[_orderID];
            return order.unitPrice;
        }
    }
    
    function dealSell(address _assetAddr, uint _orderID) returns(bool) {
        if (sellExistOf[_assetAddr]) {
            uint assetID = sellDataOf[_assetAddr];
            Order order = sellAssetList[assetID].sellOrderList[_orderID];
            Token = token(_assetAddr);
            if (Token.balanceOf(order.owner) >= order.total && EtherToken.balanceOf(msg.sender) >= order.total * order.unitPrice) {
                order.active = false;
                Token.transferFrom(order.owner,msg.sender,order.total);
                EtherToken.transferFrom(msg.sender,order.owner,order.total * order.unitPrice);
                return true;
            }
        }
        return false;
        
    }
    
    function dealBuy(address _assetAddr, uint _orderID) returns(bool) {
        if (buyExistOf[_assetAddr]) {
            uint assetID = buyDataOf[_assetAddr];
            Order order = buyAssetList[assetID].buyOrderList[_orderID];
            Token = token(_assetAddr);
            if (EtherToken.balanceOf(order.owner) >= order.total * order.unitPrice && Token.balanceOf(msg.sender) >= order.total) {
                order.active = false;
                Token.transferFrom(msg.sender,order.owner,order.total);
                EtherToken.transferFrom(order.owner,msg.sender,order.total * order.unitPrice);
                return true;
            }
        }
        return false;
    }
    
}
