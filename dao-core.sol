contract token { 
    address public daoAddr;
    address public owner;
    mapping (address => uint) public tokenBalanceOf;
    DAO daoToken;


    /*Initial */
    function token() {
        owner = msg.sender;
    }


    /* DAO functions */
    function emission(address _agentContrAddr, uint _amount) returns(bool result) {
        if(msg.sender==daoAddr) 
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
    
    function getBalance() returns(uint _balance) {
        return tokenBalanceOf[msg.sender];
    }

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
    struct Agent {
        address agentContrAddr;
        uint joinData;
    }

    function DAO(token _shares, token _credits, market _daoMarketContr, goverment _daoGovermentContr) {
        daoFounder = msg.sender;  
        daoShares = token(_shares);
        daoCredits = token(_credits);
        daoMarketContr = _daoMarketContr;
        daoGovermentContr = _daoGovermentContr;
    }
    
    function initializationDaoBalances(uint _founderSharesAmount, uint _founderCreditsAmount) returns (bool result) {
        if(!initialization) {
        daoShares.emission(msg.sender, _founderSharesAmount);
        sharesAmount = _founderSharesAmount;
        daoCredits.emission(msg.sender, _founderCreditsAmount);
        creditAmount = _founderCreditsAmount;
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

    function daoCreditEmission(uint _creditsAMount) {
        daoCredits.emission(msg.sender, _creditsAMount);
    }


    function setAgent(address _agentContAddr) returns(uint agentID) {
        if(daoShares.tokenBalanceOf(msg.sender)>0) {
            agentID = agentsList.length++;
            Agent a = agentsList[agentID];
            a.agentContrAddr = _agentContAddr;
            a.joinData = now;
            uint newAgentSharesAmount;
            newAgentSharesAmount = sharesAmount/numAgents;
            daoShares.emission(_agentContAddr, newAgentSharesAmount);
            numAgents = agentID;   
            agentDataOf[_agentContAddr] = agentID;
            agentActiveOf[_agentContAddr] = true;
            return agentID;
        }
    }

    function setAssets(address _assetAddr) returns(uint assetID) {
        if (msg.sender == daoMarketContr) {
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
    address agentAddr;
    address controlAddr;
    address daoAddr;
    DAO public dao;

    modifier controlCheck { if (msg.sender == controlAddr) _ }

    function agent(address _daoAddr) {
        agentAddr = msg.sender;
        controlAddr = msg.sender;
        daoAddr = _daoAddr;
    } 

    function setControlAddr(address _controlAddr) returns(bool result) {
        if(msg.sender == agentAddr) {
            controlAddr = _controlAddr;
        }
    }     

    function setAgent(address _agentAddr) controlCheck returns(bool result) {
        dao.setAgent(_agentAddr);
        return true;
    } 
}

contract market {
    address daoAddr;
    DAO public dao;

    struct Order {
        address owner;
        uint amount;
    }


    struct OrderList {
        address assetAddr;
        Order[] orders;
    }
    
    OrderList[] public sellList;
    mapping (address => bool) sellExistOf;
    mapping (address => uint) sellDataOf;
    
    OrderList[] public buyList;
    mapping (address => bool) buyExistOf;
    mapping (address => uint) buyDataOf;

    function getSellList(address _assetAddr) returns(uint assetID) {
        return 0;
    }

    function getBuyList(address _assetAddr) returns(uint assetID) {
        return 0;
    }

    function addSell(address _assetAddr, uint amount) returns(uint assetID) {
        return 0;
    }

    function addBuy(address _assetAddr, uint _amount) returns(uint buyID) {
        if (dao.agentActiveOf(msg.sender) && dao.assetExistOf(_assetAddr)) {
            if(buyExistOf[_assetAddr]) {
                uint assetID;
                assetID = buyDataOf[_assetAddr];
                OrderList[] buyOrders = buyList[assetID];
                buyID = buyOrders.orders.length++;
                buyOrders.orders[buyID] = Order({owner: msg.sender, amount: _amount});
                return assetID;
            }
            
        }
    }
}

contract goverment {

}
