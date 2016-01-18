contract agentStorage {
	address owner;

	modifier ownerCheck { if (msg.sender == owner) _ }

	struct Contract {
		string itemscope;
		address contractAddr;
	}
	
	Contract[] contractList;
	mapping(string => uint) contractOf;

	function agentStorage() {
		owner = msg.sender;
	}

	function setContract(string _itemscope, address _contractAddr) ownerCheck returns(bool result, uint contractID) {
		contractID = contractList.length++;
		Contract c = contractList[contractID];
		c.itemscope = _itemscope;
		c.contractAddr = _contractAddr;
		contractOf[c.itemscope] = contractID;
		result = true;
        return(result, contractID);
	}

	function getContractID(string _itemscope) ownerCheck returns(uint contractID) {
		contractID = contractOf[_itemscope];
		return contractID;
	}

	function getContractAddr(uint _contractID) returns(address) {
		Contract c = contractList[_contractID];
		return c.contractAddr;
	}
}
