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

    function setDao(address _daoAddr) {
        if(msg.sender == agentAddr) {
        	daoAddr = _daoAddr;
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
                SaleAssetList saleAssetOrders = sellAssetList[assetID];
                sellID = saleAssetOrders.sellOrderList.length++;
                saleAssetOrders.sellOrderList[sellID] = Order({orderID: sellID, owner: msg.sender, amount: _amount, price: _price});
                return assetID;
            }

        }
    }

    function addBuy(address _assetAddr, uint _amount, uint _price) returns(uint buyID) {
        if (dao.agentActiveOf(msg.sender) && dao.assetExistOf(_assetAddr)) {
            if(buyExistOf[_assetAddr]) {
                uint assetID;
                assetID = buyDataOf[_assetAddr];
                BuyAssetList buyAssetOrders = buyAssetList[assetID];
                buyID = buyAssetOrders.buyOrderList.length++;
                buyAssetOrders.buyOrderList[buyID] = Order({orderID: buyID, owner: msg.sender, amount: _amount, price: _price});
                return assetID;
            }

        }
    }


    function BuyDeal(address _assetAddr, uint _buyID) returns(bool result) {
        uint profit = msg.value*dao.daoEfficiency()/100;
        /*  TO DO */
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