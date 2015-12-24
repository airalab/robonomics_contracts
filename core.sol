contract core {
	string daoName;
	string desc;
	string owner;

	modifier ownerCheck { if (msg.sender == owner) _ }
	
	struct Template {
		string code;
		string abi;
		string actions;
		string itemscope;
		bool inactive;
	}

	Template[] templates;
	mapping (bytes32 => uint) public itemscopeTemplateOf;
	mapping (bytes32 => bool) public itemscopeTemplateExistOf;

	function core(string _daoName, string _desc) {
		daoName = _daoName;
		desc = _desc;
		owner = msg.sender;
	}

	function setTemplate(string _code,
						 string _abi,
						 string _actions,
						 string _itemscope) ownerCheck returns(bool result, uint templateID) {
		templateID = templates.length++;
		Template t = templates[templateID];
        t.code = _code;
        t.abi = _abi;
        t.actions = _actions;
        t.itemscope = _itemscope;
        result = true;
        return(result, templateID);
	}

	function getTemplate() {
		
	}
}