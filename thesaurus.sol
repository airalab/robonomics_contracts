contract thesaurus {
	string name;
	string desc;
	address owner;

	modifier ownerCheck { if (msg.sender == owner) _ }

	struct Prop {
		string itemprop;
		string itemtype;
		string desc;
	}

	Prop[] public propList;

	struct Enum {
		uint propListID;
	}
	
	struct Metadata {
		string itemscope;
		Enum  enumPropList;
	}

	Metadata[] schemaorgList;
	/* Help you find itemscope proplist*/
	mapping (bytes32 => uint) public itemscopeOf;

	function thesaurus(string _name, string _desc) {
		name = _name;
		desc = _desc;
		owner = msg.sender;
	}

	function setProp(string _itemprop, string _itemtype, string _desc) ownerCheck returns(uint propID) {
		propID = propList.length++;
        Prop p = propList[propID];
        p.itemprop = _itemprop;
        p.itemtype = _itemtype;
        p.desc = _desc;
        return propID;
	}

	function getProp(uint propID) returns(string itemprop, string itemtype, string desc){
		
	}
	
	function getTest(string _itemscope) returns(uint ID){
		ID = itemscopeOf[sha3(_itemscope)];
		return ID;
	}


}