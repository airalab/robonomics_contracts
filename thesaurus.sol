contract thesaurus {
	string public name;
	string public desc;
	address public owner;

	modifier ownerCheck { if (msg.sender == owner) _ }

	struct Prop {
		string itemprop;
		string itemtype;
		string desc;
		string dataType;
	}

	Prop[] public propList;
	mapping (bytes32 => uint) public itempropOf;
	mapping (bytes32 => bool) public itempropExistOf;

	struct Enum {
		uint propListID;
	}
	
	struct Metadata {
		string itemscope;
		Enum[]  enumPropList;
		uint numProp;
	}

	Metadata[] schemaorgList;
	/* Help you find itemscope proplist*/
	mapping (bytes32 => uint) public itemscopeOf;
	mapping (bytes32 => bool) public itemscopeExistOf;

	function thesaurus(string _name, string _desc) {
		name = _name;
		desc = _desc;
		owner = msg.sender;
	}

	function getPropID(string _itemprop) returns(bool result, uint propID){
		if(!itempropExistOf[sha3(_itemprop)]) break;
		result = true; 
		propID = itempropOf[sha3(_itemprop)];
		return(result, propID);
	}

	function getProp(uint _propID) returns(string itemprop, string itemtype, string desc, string dataType){
		Prop p = propList[_propID];
		return(p.itemprop, p.itemtype, p.desc, p.dataType);
	}

	function getMetadataID(string _itemscope) returns(bool result, uint metadataID){
		if(!itemscopeExistOf[sha3(_itemscope)]) break;
		result = true; 
		metadataID = itemscopeOf[sha3(_itemscope)];
		return(result, metadataID);
	}

	function getMetadataNumProp(uint _itemscopeID) returns(string itemscope, uint numProp){
		Metadata m = schemaorgList[_itemscopeID];
		return(m.itemscope, m.numProp);
	}
}

contract thesaurusAdmin is thesaurus{

	function setProp(string _itemprop, string _itemtype, string _desc, string _dataType) ownerCheck returns(uint propID) {
		propID = propList.length++;
        Prop p = propList[propID];
        p.itemprop = _itemprop;
        p.itemtype = _itemtype;
        p.desc = _desc;
        p.dataType = _dataType;
        itempropExistOf[sha3(p.itemprop)] = true;
        itempropOf[sha3(p.itemprop)] = propID;
        return propID;
	}

	function setMetadata(string _itemscope, uint _propID) ownerCheck returns(uint enumPropListID) {
		uint metadataID;
		if(!itemscopeExistOf[sha3(_itemscope)]) {
			metadataID = schemaorgList.length++;    	
        	itemscopeExistOf[sha3(m.itemscope)] = true;
        	itemscopeOf[sha3(m.itemscope)] = metadataID;
    	} else {
    		metadataID = itemscopeOf[sha3(_itemscope)];
    	}

    	Metadata m = schemaorgList[metadataID];
        m.itemscope = _itemscope;

        enumPropListID = m.enumPropList.length++;
       	Enum e = m.enumPropList[enumPropListID];
        e.propListID = _propID;
        m.numProp +=1;
    	return enumPropListID;
	}
}