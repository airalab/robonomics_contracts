contract agentStorage {
	address owner;

	modifier ownerCheck { if (msg.sender == owner) _ }

	struct Contract {
		string itemscope;
		address contractAddr;
	}
	
	Contract[]  contractList;
	mapping(bytes32 => uint)  contractOf;
	mapping(bytes32 => bool)  contractExistOf;

	function agentStorage() {
		owner = msg.sender;
	}

	function setContract(string _itemscope, address _contractAddr) ownerCheck returns(bool result, uint contractID) {
		contractID = contractList.length++;
		Contract c = contractList[contractID];
		c.itemscope = _itemscope;
		c.contractAddr = _contractAddr;
		contractOf[sha3(c.itemscope)] = contractID;
		contractExistOf[sha3(c.itemscope)] = true;
		result = true;
        return(result, contractID);
	}

	function getContractID(string _itemscope) ownerCheck returns(bool existing, uint contractID) {
		if(contractExistOf[sha3(_itemscope)]) {
			contractID = contractOf[sha3(_itemscope)];
			existing = true;
			return (existing, contractID);
		}
	}

	function getContractAddr(uint _contractID) ownerCheck returns(address contractAddr) {
		Contract c = contractList[_contractID];
		return(c.contractAddr);

	}


	function updContract(uint _contractID, string _itemscope, address _contractAddr) ownerCheck returns(bool result) {
		Contract c = contractList[_contractID];
		
		contractExistOf[sha3(c.itemscope)] = false;
		
		c.itemscope = _itemscope;
		c.contractAddr = _contractAddr;
		contractOf[sha3(c.itemscope)] = _contractID;
		contractExistOf[sha3(c.itemscope)] = true;
		return true;
	}
}
