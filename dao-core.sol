contract token { 
    address public creator;
    string public symbol;
    string public name;
    uint public baseUnit;
    uint totalSupply;
    mapping (address => uint) balanceOf;
    mapping (address => mapping(address => bool)) approveOf;
    mapping (address => mapping(address => bool)) approveOnceOf;
    mapping (address => mapping(address => uint)) approveOnceValueOf;

    modifier creatorCheck { if (msg.sender == creator) _ }

    /* Events */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event AddressApproval(address indexed _address, address indexed _proxy, bool _result);
    event AddressApprovalOnce(address indexed _address, address indexed _proxy, uint256 _value);

    /*Initial */
    function token() {
        creator = msg.sender;
    }

    /* Creator functions */
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
        if (balanceOf[msg.sender] + _amount < balanceOf[msg.sender]) {return false;}
        balanceOf[creator] -= _amount;
        totalSupply += _amount;
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

    function isApprovedFor(address _target, address _proxy) constant returns (bool result) {
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

contract marketAgent is agent {
    market agentMarket;
    token credit;
    
    modifier creatorCheck { if (msg.sender == creator) _ }

    function marketAgent(address _marketAddr, string _marketAbi, string _marketHelper) {
        creator = msg.sender;
        agentMarket = market(_marketAddr);
        credit.approve(agentMarket);

        uint agentContractID = agentContracts.length++;
        AgentContract a = agentContracts[agentContractID];
        a.agentContractAddr = _marketAddr;
        a.abi = _marketAbi;
        a.helper = _marketHelper;
    }
    
    function approveSupply(token _asset, uint _maxValue) creatorCheck returns(bool result) {
        token asset = token(_asset);
        result = asset.approveOnce(agentMarket, _maxValue);
        return result;
    }
}

contract market {
    address creator;
    token credit;

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

    function market(address _credit) {
        creator = msg.sender;
        credit = token(_credit);
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
}
