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
        if(dao.agentActiveOf(agentContrAddr)) {
            daoAddr = _daoAddr;
        }
    }

    /* Agent function */
    function sendToken(address receiver, uint amount) returns(bool result) {
        if (tokenBalanceOf[msg.sender] < amount) {return false;}
        tokenBalanceOf[msg.sender] -= amount;
        tokenBalanceOf[receiver] += amount;
        return true;
    }
}

contract DAO {
    address public daoFounder;
    address public daoFounderContr;
    address public daoMarketContr;
    address public daoGovermentContr;
    bool public initialization;
    uint public creditAmount;
    uint public sharesAmount;
    uint public creditTurn;
    uint public numAgents;

    token public daoShares;
    token public daoCredits;

    /* Assets data */
    Asset[] public assetsList;
    mapping (address => uint) public assetDataOf;
    mapping (address => bool) public assetExistOf;
    struct Asset {
        address assetAddr;
    }

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
    }

    function daoEfficiency() returns (uint daoEfficiency) {
        daoEfficiency = creditTurn*100/creditAmount;
    }

    function daoShareCost() returns (uint shareCost) {
        shareCost = creditTurn/sharesAmount;
    }

    function daoCreditPower() returns (uint creditPower) {
        creditPower = sharesAmount*100/creditTurn;
    }

    function daoShareSale(uint _shareAmount) returns (uint creditReward) {
        if(daoShares.tokenBalanceOf(msg.sender)>=_shareAmount) {
            creditReward = daoShareCost()*_shareAmount;
            daoCredits.emission(msg.sender, creditReward);
            daoShares.burn(msg.sender, _shareAmount);
        }
    }

    function daoShareBuy(uint _creditAmount) returns (uint shares) {
        if(daoCredits.tokenBalanceOf(msg.sender)>=_creditAmount) {
            shares = daoCreditPower()*_creditAmount;
            daoShares.emission(msg.sender, shares);
            daoCredits.burn(msg.sender, _creditAmount);
        }
    }

    function daoSharesEmission(address _agentContrAddr, uint _sharesAmount) {
        daoShares.emission(_agentContrAddr, _sharesAmount);
    }

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

    /* Agents contract list*/

    AgentContract[] public agentContractList;
    struct AgentContract {
        address agentContractAddr;
        string abi;
        string desc;
        bool active;
    }

    modifier controlCheck { if (msg.sender == controlAddr) _ }

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
    }

    function setControlAddr(address _controlAddr) returns(bool result) {
        if(msg.sender == agentAddr) {
            controlAddr = _controlAddr;
        }
    }

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
}

contract market {
    address daoAddr;
    DAO public dao;

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
    Order[] public sellOrderList;
    mapping (address => bool) public sellExistOf;
    mapping (address => uint) public sellDataOf;

    BuyAssetList[] public buyAssetList;
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
        }
    }

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
        }
    }

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

contract goverment {
    address daoAddr;
    DAO public dao;
}