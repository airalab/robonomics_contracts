contract token { 
    address public creator;
    string public symbol;
    string public name;
    uint public baseUnit;
    uint totalSupply;
    mapping (address => uint) balanceOf;

    modifier creatorCheck { if (msg.sender == creator) _ }

    /*Initial */
    function token() {
        creator = msg.sender;
    }


    /* Basic functions */
    function setSymbol(string _s) creatorCheck returns(bool result) {
        symbol = _s;
        return true;
    }
    function setName(string _n) creatorCheck returns(bool result) {
        name = _n;
        return true;
    }

    function setBaseUnit(uint _unit) creatorCheck returns(bool result) {
        baseUnit = _unit;
        return true;
    }


    function totalSupply() constant returns (uint256 supply)
    function balanceOf(address _address) constant returns (uint256 balance)
    function transfer(address _to, uint256 _value) returns (bool _success)
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success)
    function approve(address _address) returns (bool success)
    function unapprove(address _address) returns (bool success)
    function isApprovedFor(address _target, address _proxy) constant returns (bool success)
    function approveOnce(address _address, uint256 _maxValue) returns (bool success)
    function isApprovedOnceFor(address _target, address _proxy) returns (uint256 maxValue)





    /* Events */
    event Transfer(address indexed _from, address indexed _to, uint256 _value)
    event AddressApproval(address indexed _address, address indexed _proxy, bool _result)
    event AddressApprovalOnce(address indexed _address, address indexed _proxy, uint256 _value)

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

    /* Agents contract list*/

    AgentContract[] public agentContracts;
    struct AgentContract {
        address agentContractAddr;
        string abi;
    }

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

    function setNewAgent(address _agentAddr) controlCheck returns(bool result) {
        dao.setAgent(_agentAddr);
        return true;
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
    }


    struct OrderList {
        address assetAddr;
        Order[] orders;
    }
    
    OrderList[] public sellList;
    Order[] public sellOrders;
    mapping (address => bool) sellExistOf;
    mapping (address => uint) sellDataOf;
    
    OrderList[] public buyList;
    Order[] public buyOrders;
    mapping (address => bool) buyExistOf;
    mapping (address => uint) buyDataOf;


    function getSellList(address _assetAddr) returns(uint assetID) {
        return 0;
    }

    function getBuyList(address _assetAddr) returns(uint assetID) {
        return 0;
    }

    function addSell(address _assetAddr, uint _amount, uint _price) returns(uint sellID) {
        if (dao.agentActiveOf(msg.sender) && dao.assetExistOf(_assetAddr)) {
            if(sellExistOf[_assetAddr]) {
                uint assetID;
                assetID = sellDataOf[_assetAddr];
                OrderList[] assetOrders = sellList[assetID];
                sellID = sellOrders.sellOrders.length++;
                sellOrders.orders[sellID] = Order({orderID: sellID, owner: msg.sender, amount: _amount, price: _price});
                return assetID;
            }
            
        }
    }

    function addBuy(address _assetAddr, uint _amount, uint _price) returns(uint buyID) {
        if (dao.agentActiveOf(msg.sender) && dao.assetExistOf(_assetAddr)) {
            if(buyExistOf[_assetAddr]) {
                uint assetID;
                assetID = buyDataOf[_assetAddr];
                OrderList[] buyOrders = buyList[assetID];
                buyID = buyOrders.orders.length++;
                buyOrders.orders[buyID] = Order({orderID: buyID, owner: msg.sender, amount: _amount, price: _price});
                return assetID;
            }
            
        }
    }

    
    function BuyDeal(address _assetAddr, uint _buyID) {
        uint profit = msg.value*dao.daoEfficiency()/100;
        dao.daoCredits.emission(daoAddr, profit);
        return true;
    }

    function SellDeal(address _assetAddr, uint sellID) returns(bool result) {
        return true;
    }


}

contract goverment {
    address daoAddr;
    DAO public dao;



}
