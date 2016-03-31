contract core {
	string public daoName;
	string public desc;
	
	address public admin;
	address public founder;
	address public thesaurus;
	address public agentStorageTemplate;

	uint public nodesAmount;
	uint public templatesAmount;


	modifier adminCheck { if (msg.sender == admin) _ }
	
	struct DaoNode {
		string itemscope;
		string interface; // update Feb 2016 - link to GitHub raw source
		address nodeAddr;
	} 

	DaoNode[] daoNodes;
	mapping (bytes32 => uint) public daoNodeOf;
	mapping (bytes32 => bool) public daoNodeExistOf;

	struct Template {
		string itemscope;
		address templateAddr;
		string interface; // update Feb 2016 - link to GitHub raw source
		bool inactive;
	}

	Template[] templates;
	mapping (bytes32 => uint) public itemscopeTemplateOf;
	mapping (bytes32 => bool) public itemscopeTemplateExistOf;

	function core(string _daoName, string _desc) {
		daoName = _daoName;
		desc = _desc;
		admin = msg.sender;
		founder = msg.sender;
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

	function setThesaurus(address _thesaurus) adminCheck returns(bool result) {
		thesaurus = _thesaurus;
		return true;
	}

	function setAgentStorageTemplate(address _agentStorageTemplate) adminCheck returns(bool result) {
		agentStorageTemplate = _agentStorageTemplate;
		return true;
	}

	function getDaoNode(uint _daoNodeID) returns(string itemscope, string interface, address nodeAddr)
	{
		DaoNode d = daoNodes[_daoNodeID];
		return(d.itemscope, d.interface, d.nodeAddr);
	}

	function setAdmin(address _admin) adminCheck returns(bool result) {
		admin = _admin;
		return true;
	}

	function updDaoNode(uint _daoNodeID, string _itemscope, string _interface, address _nodeAddr) adminCheck returns(bool result) {
		DaoNode d = daoNodes[_daoNodeID];

		daoNodeExistOf[sha3(d.itemscope)] = false;

		d.itemscope = _itemscope;
		d.interface = _interface;
		d.nodeAddr = _nodeAddr;
		daoNodeExistOf[sha3(d.itemscope)] = true;
		daoNodeOf[sha3(d.itemscope)] = _daoNodeID;
		return true;
	}

	function setTemplate(string _interface,
						 string _itemscope,
						 address _templateAddr) adminCheck returns(bool result, uint templateID) {
		templateID = templates.length++;
		Template t = templates[templateID];
        t.interface = _interface;
        t.itemscope = _itemscope;
        t.templateAddr = _templateAddr;
        itemscopeTemplateExistOf[sha3(t.itemscope)] = true;
        itemscopeTemplateOf[sha3(t.itemscope)] = templateID;
        templatesAmount +=1;
        result = true;
        return(result, templateID);
	}

	function getTemplate(uint _templateID) returns(string itemscope, string interface, address templateAddr)
	{
		Template t = templates[_templateID];
		return(t.itemscope, t.interface, t.templateAddr);
	}
	
	function updTemplate(uint _templateID, string _itemscope, string _interface, address _templateAddr) adminCheck returns(bool result) {	
		Template t = templates[_templateID];

		itemscopeTemplateExistOf[sha3(t.itemscope)] = false;

		t.itemscope = _itemscope;
		t.interface = _interface;
		t.templateAddr = _templateAddr;

		itemscopeTemplateExistOf[sha3(t.itemscope)] = true;
		itemscopeTemplateOf[sha3(t.itemscope)] = _templateID;

		return true;
	}
	
}
