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
        daoToken = DAO(_daoAddr);
        if(daoToken.daoFounder() == msg.sender && owner == msg.sender) {
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
        uint amount;
        uint price;
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
    mapping (address => bool) sellExistOf;
    mapping (address => uint) sellDataOf;

    BuyAssetList[] public buyAssetList;
    Order[] public buyOrderList;
    mapping (address => bool) buyExistOf;
    mapping (address => uint) buyDataOf;

    function setDao(address _daoAddr) {
		daoAddr = _daoAddr;
		dao = DAO(daoAddr);
    }

    function getSellList(address _assetAddr) returns(uint assetID) {
        return 0;
    }

    function getBuyList(address _assetAddr) returns(uint assetID) {
        return 0;
    }

    function addSell(address _assetAddr, uint _amount, uint _price) returns(uint sellID) {
    	address agentContrAddr = dao.agentContractOf(msg.sender);
        if (dao.agentActiveOf(agentContrAddr) && dao.assetExistOf(_assetAddr)) {
        	uint assetID;
            if (sellExistOf[_assetAddr]) {
                assetID = sellDataOf[_assetAddr];
                SaleAssetList sellAssetOrders = sellAssetList[assetID];
                sellID = sellAssetOrders.sellOrderList.length++;
                sellAssetOrders.sellOrderList[sellID] = Order({orderID: sellID, owner: agentContrAddr, amount: _amount, price: _price, active: true});
                return sellID;
            } else {
            	assetID = sellAssetList.length++;
				sellExistOf[_assetAddr] = true;
                sellAssetOrders = sellAssetList[assetID];
                sellAssetOrders.assetAddr = _assetAddr;
				sellID = sellAssetOrders.sellOrderList.length++;
                sellAssetOrders.sellOrderList[sellID] = Order({orderID: sellID, owner: agentContrAddr, amount: _amount, price: _price, active: true});
				return sellID;
            }
        }
    }

    function getSellId(address _assetAddr, uint _amount) returns(uint sellID) {
		if (sellExistOf[_assetAddr]) {
			uint assetID = sellDataOf[_assetAddr];
			uint i;
			uint min = 0;
			for (i = 0; i <= sellAssetList[assetID].sellOrderList.length - 1; i++) {
				if (sellAssetList[assetID].sellOrderList[i].active == true && sellAssetList[assetID].sellOrderList[i].amount == _amount && (sellAssetList[assetID].sellOrderList[i].price < min || min == 0)) {
					min = sellAssetList[assetID].sellOrderList[i].price;
					sellID = i;
				}
			}
		}
		return sellID;
    }

    function addBuy(address _assetAddr, uint _amount, uint _price) returns(uint buyID) {
    	address agentContrAddr = dao.agentContractOf(msg.sender);
		if (dao.agentActiveOf(agentContrAddr) && dao.assetExistOf(_assetAddr)) {
			uint assetID;
			if (buyExistOf[_assetAddr]) {
				assetID = buyDataOf[_assetAddr];
				BuyAssetList buyAssetOrders = buyAssetList[assetID];
				buyID = buyAssetOrders.buyOrderList.length++;
				buyAssetOrders.buyOrderList[buyID] = Order({orderID: buyID, owner: agentContrAddr, amount: _amount, price: _price, active: true});
				return buyID;
			} else {
				assetID = buyAssetList.length++;
				buyExistOf[_assetAddr] = true;
				buyAssetOrders = buyAssetList[assetID];
				buyAssetOrders.assetAddr = _assetAddr;
				buyID = buyAssetOrders.buyOrderList.length++;
				buyAssetOrders.buyOrderList[buyID] = Order({orderID: buyID, owner: agentContrAddr, amount: _amount, price: _price, active: true});
				return buyID;
			}
		}
    }

    function getBuyId(address _assetAddr, uint _amount) returns(uint buyID) {
		if (buyExistOf[_assetAddr]) {
            uint assetID = buyDataOf[_assetAddr];
			uint i;
			uint max = 0;
			for (i = 0; i <= buyAssetList[assetID].buyOrderList.length - 1; i++) {
            	if (buyAssetList[assetID].buyOrderList[i].active == true && buyAssetList[assetID].buyOrderList[i].amount == _amount && (buyAssetList[assetID].buyOrderList[i].price > max || max == 0)) {
            		max = buyAssetList[assetID].buyOrderList[i].price;
            		buyID = i;
            	}
            }
		}
        return buyID;
    }

    function BuyDeal(address _assetAddr, uint _buyID) returns(bool result) {
		if (sellExistOf[_assetAddr]) {
            uint assetID = sellDataOf[_assetAddr];
			Order order = sellAssetList[assetID].sellOrderList[_buyID];

			address agent_buy_addr = dao.agentContractOf(msg.sender);
			agent agent_buy = agent(agent_buy_addr);
			agent_buy.sendToken(dao.daoCredits(), order.owner, order.price);

			agent agent_sell = agent(order.owner);
			agent_sell.sendToken(sellAssetList[assetID].assetAddr, agent_buy_addr, order.amount);

			/*order.buyer = agent_buy_addr;*/
			order.active = false;
			return true;
        }
        return false;
    }

    function SellDeal(address _assetAddr, uint sellID) returns(bool result) {
        if (buyExistOf[_assetAddr]) {
			uint assetID = buyDataOf[_assetAddr];
			BuyAssetList buyAsset = buyAssetList[assetID];
			Order order = buyAsset.buyOrderList[sellID];

			address agent_sell_addr = dao.agentContractOf(msg.sender);
			agent agent_sell = agent(agent_sell_addr);
			agent_sell.sendToken(buyAsset.assetAddr, order.owner, order.amount);

			agent agent_buy = agent(order.owner);
			agent_buy.sendToken(dao.daoCredits(), agent_sell_addr, order.price);

			/*order.buyer = agent_sell_addr;*/
			order.active = false;
			return true;
		}
		return false;
    }
}

contract goverment {
    address daoAddr;
    DAO public dao;
}