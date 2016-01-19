contract core {
	string public daoName;
	string public desc;
	address public admin;
	uint public nodesAmount;
	uint public templatesAmount;

	modifier adminCheck { if (msg.sender == admin) _ }
	
	struct DaoNode {
	    string itemscope;
		string interface;
		address nodeAddr;
	} 

	DaoNode[] daoNodes;
	mapping (bytes32 => uint) public daoNodeOf;
	mapping (bytes32 => bool) public daoNodeExistOf;

	struct Template {
		string itemscope;
		string interface;
		bool inactive;
	}

	Template[] templates;
	mapping (bytes32 => uint) public itemscopeTemplateOf;
	mapping (bytes32 => bool) public itemscopeTemplateExistOf;

	function core(string _daoName, string _desc) {
		daoName = _daoName;
		desc = _desc;
		admin = msg.sender;
	}

	function setDaoNode(string _itemscope,
	                    string _interface,
						address _nodeAddr) adminCheck returns(bool result, uint daoNodeID) {
		daoNodeID = daoNodes.length++;
		DaoNode d = daoNodes[daoNodeID];
		d.itemscope = _itemscope;
		d.interface = _interface;
		d.nodeAddr = _nodeAddr;
		result = true;
		nodesAmount +=1;
		daoNodeOf[sha3(d.itemscope)] = daoNodeID;
		daoNodeExistOf[sha3(d.itemscope)] = true;
        return(result, daoNodeID);
	}

	function getDaoNode(uint _daoNodeID) returns(string itemscope, string interface, address nodeAddr)
	{
		DaoNode d = daoNodes[_daoNodeID];
		return(d.itemscope, d.interface, d.nodeAddr);
	}

	function setTemplate(string _interface,
						 string _itemscope) adminCheck returns(bool result, uint templateID) {
		templateID = templates.length++;
		Template t = templates[templateID];
        t.interface = _interface;
        t.itemscope = _itemscope;
        itemscopeTemplateExistOf[sha3(t.itemscope)] = true;
        itemscopeTemplateOf[sha3(t.itemscope)] = templateID;
        templatesAmount +=1;
        result = true;
        return(result, templateID);
	}

	function getTemplate(uint _templateID) returns(string itemscope, string interface)
	{
		Template t = templates[_templateID];
		return(t.itemscope, t.interface);
	}
}