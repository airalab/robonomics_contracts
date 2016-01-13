contract core {
	string public daoName;
	string public desc;
	address public admin;

	modifier adminCheck { if (msg.sender == admin) _ }
	
	struct DaoNode {
		string interface;
		string code;
	} 

	DaoNode[] daoNodes;

	struct Template {
		string code;
		string interface;
		string actions;
		string itemscope;
		address thesaurus;
		bool inactive;
	}

	Template[] templates;
	mapping (string => uint) public itemscopeTemplateOf;
	mapping (string => bool) public itemscopeTemplateExistOf;

	function core(string _daoName, string _desc) {
		daoName = _daoName;
		desc = _desc;
		admin = msg.sender;
	}

	function setDaoNode(string _interface,
						string _code) adminCheck returns(bool result, uint daoNodeID) {
		daoNodeID = daoNodes.length++;
		DaoNode d = daoNodes[daoNodeID];
		d.interface = _interface;
		d.code = _code;
		result = true;
        return(result, daoNodeID);
	}

	function getDaoNode() {}

	function setTemplate(string _code,
						 string _interface,
						 string _actions,
						 string _itemscope,
						 address _thesaurus) adminCheck returns(bool result, uint templateID) {
		templateID = templates.length++;
		Template t = templates[templateID];
        t.code = _code;
        t.interface = _interface;
        t.actions = _actions;
        t.itemscope = _itemscope;
        t.thesaurus = _thesaurus;
        itemscopeTemplateExistOf[t.itemscope] = true;
        itemscopeTemplateOf[t.itemscope] = templateID;
        result = true;
        return(result, templateID);
	}

	function getTemplate() {}
}