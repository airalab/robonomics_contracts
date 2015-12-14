contract token { 
    address public creator;
    string public symbol;
    string public name;
    uint public baseUnit;
    uint totalSupply;
    mapping (address => uint) public balanceOf;
    mapping (address => mapping(address => bool)) approveOf;
    mapping (address => mapping(address => bool)) approveOnceOf;
    mapping (address => mapping(address => uint)) approveOnceValueOf;

    modifier creatorCheck { if (msg.sender == creator) _ }

    /* Events */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event AddressApproval(address indexed _address, address indexed _proxy, bool _result);
    event AddressApprovalOnce(address indexed _address, address indexed _proxy, uint256 _value);

    /*Initial */
    function token(string _s, string _n, uint _unit) {
        creator = msg.sender;
        symbol = _s;
        name = _n;
        baseUnit = _unit;
    }

    /* Creator functions */
    function getTotalSupply()  creatorCheck returns (uint supply) {
        return totalSupply;
    }

    function emmision(uint _amount) creatorCheck returns(bool result) {
        if (balanceOf[creator] + _amount < balanceOf[creator]) {return false;}
        balanceOf[creator] += _amount;
        totalSupply += _amount;
        return true;
    }

    function burn(uint _amount) creatorCheck returns(bool result) {
        if (balanceOf[creator] < _amount) {return false;}
        if (balanceOf[creator] + _amount < balanceOf[creator]) {return false;}
        balanceOf[creator] -= _amount;
        totalSupply -= _amount;
        return true;
    }

    /* Agent function */

    function myBalance() returns (uint256 balance) {
        balance = balanceOf[msg.sender];
        return balance;
    }

    function transfer(address _to, uint256 _value) returns (bool result) {
        if (balanceOf[msg.sender] < _value) {return false;}
        if (balanceOf[msg.sender] + _value < balanceOf[msg.sender]) {return false;}
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if(approveOf[_from][msg.sender])
        {
            if (balanceOf[_from] < _value) {return false;}
            if (balanceOf[_from] + _value < balanceOf[_from]) {return false;}
            balanceOf[_from] -= _value;
            balanceOf[_to] += _value;  
            Transfer(_from, _to, _value);          
            return true;
        } else if(approveOnceOf[_from][msg.sender] && approveOnceValueOf[_from][msg.sender]<=_value) {
            if (balanceOf[_from] < _value) {return false;}
            if (balanceOf[_from] + _value < balanceOf[_from]) {return false;}
            balanceOf[_from] -= _value;
            balanceOf[_to] += _value;  
            Transfer(_from, _to, _value);          
            return true;  
        }
    }

    function approve(address _address) returns (bool result) {
        approveOf[msg.sender][_address] = true;
        AddressApproval(_address, msg.sender, true);
        return true;
    }

    function unapprove(address _address) returns (bool result) {
        approveOf[msg.sender][_address] = false;
        return true;        
    }

    function approveOnce(address _address, uint _maxValue) returns (bool result) {
        approveOnceOf[msg.sender][_address] = true;
        approveOnceValueOf[msg.sender][_address] = _maxValue;
        AddressApprovalOnce(_address, msg.sender, _maxValue);
        return true;       
    }

    function unapproveOnce(address _address) returns (bool result) {
        approveOnceOf[msg.sender][_address] = false;
        approveOnceValueOf[msg.sender][_address] = 0;
        return true;       
    }

    function isApprovedOnceFor(address _target, address _proxy) returns (uint maxValue) {
        maxValue = approveOnceValueOf[_target][_proxy];
        return maxValue;
    }

    function isApprovedFor(address _target, address _proxy) returns (bool result) {
        result = approveOnceOf[_target][_proxy];
        return result;
    }
}


contract agent {
    address creator;

    modifier creatorCheck { if (msg.sender == creator) _ }

    /* Struct */
    AgentContract[] public agentContracts;

    struct AgentContract {
        address agentContractAddr;
        string abi;
        string helper;
    }

    /* Functions */
    function agent() {
        creator = msg.sender;
    }

    function setAgentContract(address _agentContractAddr, string _abi, string _helper) creatorCheck returns(uint agentContractID) {
        agentContractID = agentContracts.length++;
        AgentContract a = agentContracts[agentContractID];
        a.agentContractAddr = _agentContractAddr;
        a.abi = _abi;
        a.helper = _helper;
        return (agentContractID);
    }    
}

contract marketAgent {
    address creator;
    market Market;

    modifier creatorCheck { if (msg.sender == creator) _ }

    function marketAgent(address _marketAddr, string _marketAbi, string _marketHelper) {
        creator = msg.sender;
        Market = market(_marketAddr);
        Market.credit().approve(_marketAddr);
    }
    
    function approveSupply(token _asset, uint _maxValue) creatorCheck returns(bool result) {
        token asset = token(_asset);
        result = asset.approveOnce(Market, _maxValue);
        return result;
    }

    function addSell(token _assetAddr, uint _total, uint _unitPrice, uint _min, uint _step) returns(uint) {
        if (token(_assetAddr).myBalance() >= _total) {
            approveSupply(_assetAddr, _total);
            return Market.addSell(_assetAddr, _total, _unitPrice, _min, _step);
        }
    }

    function addBuy(address _assetAddr, uint _total, uint _unitPrice, uint _min, uint _step) returns(uint) {
        if (Market.credit().myBalance() >= (_total * _unitPrice)) {
            return Market.addBuy(_assetAddr, _total, _unitPrice, _min, _step);
        }
    }

    function removeSell(address _assetAddr, uint _orderID) returns(bool) {
        return Market.removeSell(_assetAddr, _orderID);
    }

    function removeBuy(address _assetAddr, uint _orderID) returns(bool) {
        return Market.removeBuy(_assetAddr, _orderID);
    }

    function buyDeal(address _assetAddr, uint _amount, uint _orderID) returns(bool) {
        return Market.buyDeal(_assetAddr, _amount, _orderID);
    }

    function sellDeal(token _assetAddr, uint _amount, uint _orderID) returns(bool) {
        if (token(_assetAddr).myBalance() >= _amount) {
            approveSupply(_assetAddr, _amount);
            return Market.sellDeal(_assetAddr, _amount, _orderID);
        }
    }
}

contract market {
    address creator;
    token public credit;

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

    BuyAssetList[] public buyAssetList;
    mapping (address => bool) public buyExistOf;
    mapping (address => uint) public buyDataOf;

    function market(address _credit) {
        creator = msg.sender;
        credit = token(_credit);
    }

    function addSell(address _assetAddr, uint _total, uint _unitPrice, uint _min, uint _step) returns(uint sellID) {
        uint assetID;
        if (sellExistOf[_assetAddr]) {
            assetID = sellDataOf[_assetAddr];
            SaleAssetList sellAssetOrders = sellAssetList[assetID];
        } else {
            assetID = sellAssetList.length++;
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

        return sellID;
    }

    function addBuy(address _assetAddr, uint _total, uint _unitPrice, uint _min, uint _step) returns(uint buyID) {
        uint assetID;
        if (buyExistOf[_assetAddr]) {
            assetID = buyDataOf[_assetAddr];
            BuyAssetList buyAssetOrders = buyAssetList[assetID];
        } else {
            assetID = buyAssetList.length++;
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

    function buyDeal(address _assetAddr, uint _amount, uint _orderID) returns(bool) {
        if (sellExistOf[_assetAddr]) {
            uint assetID = sellDataOf[_assetAddr];
            Order order = sellAssetList[assetID].sellOrderList[_orderID];
            if (order.total > 0 && order.active == true && _amount >= order.min && _amount <= order.total && ((_amount / order.step) * order.step) == _amount) {
                marketAgent agentBuy = marketAgent(msg.sender);
                marketAgent agentSell = marketAgent(order.owner);
                token asset = token(sellAssetList[assetID].assetAddr);
                uint totalCredit = order.unitPrice * _amount;
                if (credit.isApprovedFor(agentBuy, this) &&
                    credit.isApprovedOnceFor(agentBuy, this) >= totalCredit &&
                    credit.balanceOf(agentBuy) >= totalCredit &&
                    asset.isApprovedFor(agentSell, this) &&
                    asset.isApprovedOnceFor(agentSell, this) >= _amount &&
                    asset.balanceOf(agentSell) >= _amount)
                {
                    credit.transferFrom(agentBuy, agentSell, totalCredit);
                    asset.transferFrom(agentSell, agentBuy, _amount);
                    order.total = order.total - _amount;
                    if (order.total == 0) {
                        order.active = false;
                    }
                    return true;
                }
            }
        }
        return false;
    }

    function sellDeal(address _assetAddr, uint _amount, uint _orderID) returns(bool) {
        if (buyExistOf[_assetAddr]) {
            uint assetID = buyDataOf[_assetAddr];
            Order order = buyAssetList[assetID].buyOrderList[_orderID];
            if (order.total > 0 && order.active == true && _amount >= order.min && _amount <= order.total && ((_amount / order.step) * order.step) == _amount) {
                marketAgent agentSell = marketAgent(msg.sender);
                marketAgent agentBuy = marketAgent(order.owner);
                token asset = token(buyAssetList[assetID].assetAddr);
                uint totalCredit = order.unitPrice * _amount;
                if (credit.isApprovedFor(agentBuy, this) &&
                    credit.isApprovedOnceFor(agentBuy, this) >= totalCredit &&
                    credit.balanceOf(agentBuy) >= totalCredit &&
                    asset.isApprovedFor(agentSell, this) &&
                    asset.isApprovedOnceFor(agentSell, this) >= _amount &&
                    asset.balanceOf(agentSell) >= _amount)
                {
                    credit.transferFrom(agentBuy, agentSell, totalCredit);
                    asset.transferFrom(agentSell, agentBuy, _amount);
                    order.total = order.total - _amount;
                    if (order.total == 0) {
                        order.active = false;
                    }
                    return true;
                }
            }
        }
        return false;
    }
}

contract goverment {
    address creator;
    token shares;
    token credits;

    /* info for market */
    mapping (address => bool) public banAssetOf;
    mapping (address => bool) public banAgentOf;



    struct MarketDeal {
        address asset;
        address seller;
        address buyer;
        uint amount;
        uint price;
    }

    struct Rule {
        address creator;
        address asset;
        uint percentEmmision;
        uint percentBurn;
        uint positive;
        uint negative;
    }

    Rule[] proposals;

    function goverment(string _s, string _n, uint _unit) {
        creator = msg.sender;
        shares = new token(_s, _n, _unit);
        credits = new token(_s, _n, _unit);
    }

    function getDaoEfficiently() returns(uint daoEfficiently) {

    }

    function setProposal(address _asset, uint _percentEmmision, uint _percentBurn) {
        if(shares.isApprovedFor(msg.sender, this)) {
            uint proposalID = proposals.length++;
            Rule r = proposals[proposalID];

        }
    }

    
}

contract creditControl is goverment {

    /* info for goverment */
    mapping (address => bool) public existRuleAssetOf;
    mapping (address => bool) public existRuleBuyerOf;
    mapping (address => bool) public existRuleSellerOf;
    mapping (address => uint) public ruleIdAssetOf;
    mapping (address => uint) public ruleIdBuyerOf;
    mapping (address => uint) public ruleIdSellerOf;

    function creditControl()   {}
    
    function newMarketDeal(address _asset, address _seller, address _buyer, uint _amount, uint _price) {
        if(existRuleAssetOf[_asset]) {
            uint ruleID;
            ruleID = ruleIdAssetOf[_asset];
            Rule assetRule = proposals[ruleID];
            credits.emmision(assetRule.percentEmmision*_price);
            credits.burn(assetRule.percentBurn*_price);
        }
    }
}


contract institute {

}

contract DAO {
    address public creator;
    token public shares;
    token public credits;
    market public daoMarket;
    address public daoGoverment;

    modifier govermentCheck { if (msg.sender == daoGoverment) _ }

    function DAO() {

    }

    function creditEmmision(uint _amount) govermentCheck returns(bool result) {
            result = credits.emmision(_amount);
            return result;
    }

    function creditBurn(uint _amount) govermentCheck returns(bool result) {
            result = credits.burn(_amount);
            return result;
    }

    function shareEmmision(uint _amount) govermentCheck returns(bool result) {
            result = shares.emmision(_amount);
            return result;
    }

    function shareBurn(uint _amount) govermentCheck returns(bool result) {
            result = shares.burn(_amount);
            return result;
    }


}