<<<<<<< HEAD
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
=======
contract token {
    string public assetName;
    address public daoAddr;
    address public owner;
    mapping (address => uint) public tokenBalanceOf;
    DAO daoToken;

    /*Initial */
    function token(string _assetName) {
        assetName = _assetName;
        owner = msg.sender;
    }

    /* DAO functions */
    function emission(address _agentContrAddr, uint _amount) returns(bool result) {
        if(msg.sender==daoAddr || msg.sender==owner)
        {
            tokenBalanceOf[_agentContrAddr] += _amount;
            return true;
        }
        return false;
    }

    function burn(address _agentContrAddr, uint _amount) returns(bool result) {
        if(msg.sender==daoAddr && tokenBalanceOf[_agentContrAddr]>=_amount)
        {
            tokenBalanceOf[_agentContrAddr] -= _amount;
            return true;
        }
        return false;
    }

    function setDaoAddr(address _daoAddr) {
        DAO dao = DAO(_daoAddr);
        address agentContrAddr = dao.agentContractOf(msg.sender);
        if(dao.agentActiveOf(agentContrAddr) || dao.daoFounder() == msg.sender) {
            daoAddr = _daoAddr;
        }
    }

    /* Agent function */
    function sendToken(address receiver, uint amount) returns(bool result) {
        if (tokenBalanceOf[msg.sender] < amount) {return false;}
        tokenBalanceOf[msg.sender] -= amount;
        tokenBalanceOf[receiver] += amount;
        return true;
>>>>>>> refs/remotes/origin/master
    }

    function transfer(address _to, uint256 _value) returns (bool result) {
        if (balanceOf[msg.sender] < _value) {return false;}
        if (balanceOf[msg.sender] + _value < balanceOf[msg.sender]) {return false;}
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

<<<<<<< HEAD
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
=======
    /* Agents data */
    Agent[] public agentsList;
    mapping (address => uint) public agentDataOf;
    mapping (address => bool) public agentActiveOf;
    mapping (address => address) public agentContractOf;
    struct Agent {
        address agentContrAddr;
        uint joinData;
    }

    function DAO(token _shares, token _credits, agent _daoFounderContr, market _daoMarketContr, goverment _daoGovermentContr) {
        daoFounder = msg.sender;
        daoShares = token(_shares);
        daoCredits = token(_credits);
        daoFounderContr = _daoFounderContr;
        daoMarketContr = _daoMarketContr;
        daoGovermentContr = _daoGovermentContr;
    }

    function setMarket(address _daoMarketContr) {
        if(msg.sender == daoFounder) {
        	daoMarketContr = _daoMarketContr;
        }
    }

    function initializationDaoBalances(uint _founderSharesAmount, uint _founderCreditsAmount) returns (bool result) {
        if(!initialization) {
			daoShares.emission(daoFounderContr, _founderSharesAmount);
			sharesAmount = _founderSharesAmount;
			daoCredits.emission(daoFounderContr, _founderCreditsAmount);
			creditAmount = _founderCreditsAmount;
			initialization = true;
			return true;
        }
>>>>>>> refs/remotes/origin/master
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

<<<<<<< HEAD
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
=======
    function daoCreditEmission(address _agentContrAddr, uint _creditsAmount) {
        daoCredits.emission(_agentContrAddr, _creditsAmount);
    }

    function setAgent(address _agentContAddr) returns(uint agentID) {
        if(daoShares.tokenBalanceOf(msg.sender)>0) {
            agentID = agentsList.length++;
            Agent a = agentsList[agentID];
            a.agentContrAddr = _agentContAddr;
            a.joinData = now;
            uint newAgentSharesAmount;
            numAgents = agentID + 1;
            newAgentSharesAmount = sharesAmount/numAgents*daoEfficiency();
            daoShares.emission(_agentContAddr, newAgentSharesAmount);
            agentDataOf[_agentContAddr] = agentID;
            agentActiveOf[_agentContAddr] = true;
            agent Agn = agent(_agentContAddr);
            agentContractOf[Agn.agentAddr()] = _agentContAddr;
            return agentID;
        }
    }

    function setAssets(address _assetAddr) returns(uint assetID) {
        if (agentActiveOf[msg.sender] == true) {
            assetID = assetsList.length++;
            Asset a = assetsList[assetID];
            a.assetAddr = _assetAddr;
            assetDataOf[_assetAddr] = assetID;
            assetExistOf[_assetAddr] = true;
            return assetID;
        }
    }
}

contract agent {
    address public agentAddr;
    address controlAddr;
    address daoAddr;
    DAO public dao;
>>>>>>> refs/remotes/origin/master

    function addBuy(address _assetAddr, uint _total, uint _unitPrice, uint _min, uint _step) returns(uint) {
        if (Market.credit().myBalance() >= (_total * _unitPrice)) {
            return Market.addBuy(_assetAddr, _total, _unitPrice, _min, _step);
        }
    }

<<<<<<< HEAD
    function removeSell(address _assetAddr, uint _orderID) returns(bool) {
        return Market.removeSell(_assetAddr, _orderID);
=======
    AgentContract[] public agentContractList;
    struct AgentContract {
        address agentContractAddr;
        string abi;
        string desc;
        bool active;
>>>>>>> refs/remotes/origin/master
    }

    function removeBuy(address _assetAddr, uint _orderID) returns(bool) {
        return Market.removeBuy(_assetAddr, _orderID);
    }

<<<<<<< HEAD
    function buyDeal(address _assetAddr, uint _amount, uint _orderID) returns(bool) {
        return Market.buyDeal(_assetAddr, _amount, _orderID);
=======
    function agent() {
        agentAddr = msg.sender;
        controlAddr = msg.sender;
    }

    function addAsset(address _tokenAddr) {
        if (msg.sender == agentAddr) {
			dao.setAssets(_tokenAddr);
		}
    }

    function sendToken(address assetAddr, address receiver, uint amount) {
        if (msg.sender == agentAddr || msg.sender == dao.daoMarketContr()) {
			token asset = token(assetAddr);
			asset.sendToken(receiver, amount);
		}
    }

    function setDao(address _daoAddr) {
        if(msg.sender == agentAddr) {
        	daoAddr = _daoAddr;
			dao = DAO(daoAddr);
        }
>>>>>>> refs/remotes/origin/master
    }

    function sellDeal(token _assetAddr, uint _amount, uint _orderID) returns(bool) {
        if (token(_assetAddr).myBalance() >= _amount) {
            approveSupply(_assetAddr, _amount);
            return Market.sellDeal(_assetAddr, _amount, _orderID);
        }
    }
<<<<<<< HEAD
=======

    function setNewAgent(address _agentAddr) controlCheck returns(bool result) {
        dao.setAgent(_agentAddr);
        return true;
    }

    function setAgentContract(address _agentContractAddr, string _abi, string _desc) controlCheck returns(uint contractID) {
        contractID = agentContractList.length++;
        AgentContract a = agentContractList[contractID];
        a.agentContractAddr = _agentContractAddr;
        a.abi = _abi;
        a.desc = _desc;
        a.active = true;
        return contractID;
    }

    function inactiveAgentContract(address _agentContractAddr) controlCheck returns(bool result) {

    }
>>>>>>> refs/remotes/origin/master
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
<<<<<<< HEAD
=======
    Order[] public sellOrderList;
>>>>>>> refs/remotes/origin/master
    mapping (address => bool) public sellExistOf;
    mapping (address => uint) public sellDataOf;

    BuyAssetList[] public buyAssetList;
<<<<<<< HEAD
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
=======
    Order[] public buyOrderList;
    mapping (address => bool) public buyExistOf;
    mapping (address => uint) public buyDataOf;

    function setDao(address _daoAddr) {
		daoAddr = _daoAddr;
		dao = DAO(daoAddr);
    }

    function addSell(address _assetAddr, uint _total, uint _unitPrice, uint _min, uint _step) returns(uint sellID) {
    	address agentContrAddr = dao.agentContractOf(msg.sender);
        if (dao.agentActiveOf(agentContrAddr) && dao.assetExistOf(_assetAddr)) {
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
			order.owner = agentContrAddr;
			order.total = _total;
			order.unitPrice = _unitPrice;
			order.min = _min;
			order.step = _step;
			order.active = true;

			return sellID;
>>>>>>> refs/remotes/origin/master
        }
        return false;
    }

<<<<<<< HEAD
    function removeBuy(address _assetAddr, uint _orderID) returns(bool) {
        if (buyExistOf[_assetAddr]) {
            uint assetID = buyDataOf[_assetAddr];
            Order order = buyAssetList[assetID].buyOrderList[_orderID];
            if (order.owner == msg.sender) {
                order.active = false;
                return true;
            }
=======
    function addBuy(address _assetAddr, uint _total, uint _unitPrice, uint _min, uint _step) returns(uint buyID) {
    	address agentContrAddr = dao.agentContractOf(msg.sender);
        if (dao.agentActiveOf(agentContrAddr) && dao.assetExistOf(_assetAddr)) {
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
			order.owner = agentContrAddr;
			order.total = _total;
			order.unitPrice = _unitPrice;
			order.min = _min;
			order.step = _step;
			order.active = true;

			return buyID;
>>>>>>> refs/remotes/origin/master
        }
        return false;
    }

<<<<<<< HEAD
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
=======
    function removeSell(address _assetAddr, uint _orderID) returns(bool result) {
    	if (sellExistOf[_assetAddr]) {
    		address agentContrAddr = dao.agentContractOf(msg.sender);
			uint assetID = sellDataOf[_assetAddr];
			Order order = sellAssetList[assetID].sellOrderList[_orderID];
			if (order.owner == agentContrAddr) {
				order.active = false;
				return true;
			}
		}
		return false;
    }

    function removeBuy(address _assetAddr, uint _orderID) returns(bool result) {
    	if (buyExistOf[_assetAddr]) {
    		address agentContrAddr = dao.agentContractOf(msg.sender);
			uint assetID = buyDataOf[_assetAddr];
			Order order = buyAssetList[assetID].buyOrderList[_orderID];
			if (order.owner == agentContrAddr) {
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

    function BuyDeal(address _assetAddr, uint _amount, uint _orderID) returns(bool result) {
		if (sellExistOf[_assetAddr]) {
            uint assetID = sellDataOf[_assetAddr];
			Order order = sellAssetList[assetID].sellOrderList[_orderID];
			if (order.total > 0 && order.active == true && _amount >= order.min && _amount <= order.total && ((_amount / order.step) * order.step) == _amount) {
				address agent_buy_addr = dao.agentContractOf(msg.sender);
				agent agent_buy = agent(agent_buy_addr);
				agent agent_sell = agent(order.owner);

				token credit = token(dao.daoCredits());
				if (credit.tokenBalanceOf(agent_buy_addr) < (order.unitPrice * _amount)) {
					return false;
				}
				token asset = token(sellAssetList[assetID].assetAddr);
				if (asset.tokenBalanceOf(order.owner) < _amount) {
					return false;
				}

				agent_buy.sendToken(dao.daoCredits(), order.owner, (order.unitPrice * _amount));
				agent_sell.sendToken(sellAssetList[assetID].assetAddr, agent_buy_addr, _amount);

				order.total = order.total - _amount;
				if (order.total == 0) {
					order.active = false;
				}
				return true;
			}
		}
        return false;
    }

    function SellDeal(address _assetAddr, uint _amount, uint _orderID) returns(bool result) {
        if (buyExistOf[_assetAddr]) {
			uint assetID = buyDataOf[_assetAddr];
			Order order = buyAssetList[assetID].buyOrderList[_orderID];
			if (order.total > 0 && order.active == true && _amount >= order.min && _amount <= order.total && ((_amount / order.step) * order.step) == _amount) {
				address agent_sell_addr = dao.agentContractOf(msg.sender);
				agent agent_sell = agent(agent_sell_addr);
				agent agent_buy = agent(order.owner);

				token credit = token(dao.daoCredits());
				if (credit.tokenBalanceOf(order.owner) < (order.unitPrice * _amount)) {
					return false;
				}
				token asset = token(buyAssetList[assetID].assetAddr);
				if (asset.tokenBalanceOf(agent_sell_addr) < _amount) {
					return false;
				}

				agent_sell.sendToken(buyAssetList[assetID].assetAddr, order.owner, _amount);
				agent_buy.sendToken(dao.daoCredits(), agent_sell_addr, (order.unitPrice * _amount));

				order.total = order.total - _amount;
				if (order.total == 0) {
					order.active = false;
				}
				return true;
			}
		}
		return false;
    }
}

contract rule {
    address seller;
    address buyer; 
    address asset;  
    uint qty;
    uint fullCost;
    uint dealTimestamp;
    
    function execute(address _seller , address _buyer, address  _asset,  uint _qty, uint _fullCost) returns(address seller, address buyer, address asset, address qty, uint fullCost) {
>>>>>>> refs/remotes/origin/master
    }
}

contract goverment {
<<<<<<< HEAD
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
=======
    address daoAddr;

    function goverment(address _daoAddr) {
        daoAddr = _daoAddr;
    }

    /* market data */
    
    struct MarketDeal {
        address seller;
        address buyer; 
        address asset;  
        uint qty;
        uint fullCost;
        uint dealTimestamp;
    }
>>>>>>> refs/remotes/origin/master

    MarketDeal[] public marketDeals;
    
    /* proposal data */
    
    mapping (address => uint) public sellerRulesFilterExistOf;
    mapping (address => uint) public buyerRulesFilterExistOf;
    mapping (address => uint) public assetRulesFilterExistOf;
    mapping (address => uint) public sellerRulesFilterOf;
    mapping (address => uint) public buyerRulesFilterOf;
    mapping (address => uint) public assetRulesFilterOf;
    
    
    /* proposal data */
    function setMarketDeal(address _seller , address _buyer, address  _asset,  uint _qty, uint _fullCost) returns(bool result) {
        marketDeals[marketDeals.length++] = MarketDeal({seller: _seller, buyer: _buyer, asset: _asset, qty: _qty, fullCost: _fullCost, dealTimestamp: now});
    }
    
    function executeRule(address _ruleAddr, uint _marketDealID) {
        rule executingRule;
        executingRule = rule(_ruleAddr);
        address seller = marketDeals[_marketDealID].seller;
        address buyer = marketDeals[_marketDealID].buyer;
        address asset = marketDeals[_marketDealID].asset;
        uint qty = marketDeals[_marketDealID].qty;
        uint fullCost = marketDeals[_marketDealID].fullCost;
        
        executingRule.execute(seller,buyer,asset,qty,fullCost);
        
    }
    
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