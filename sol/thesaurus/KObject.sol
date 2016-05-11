import './Knowledge.sol';

/**
 * The knowledge object represents the real world object
 * that can be consist of some another objects and have
 * a count of attributes
 */
contract KObject is Knowledge {
    /* Object constructor */
    function KObject() Knowledge(OBJECT) {}

    /* List of object property names */
    string[] public propertyList;

    function propertyLength() constant returns (uint)
    { return propertyList.length; }

    /* Hash name to value mapping */
    mapping (bytes32 => string)  public propertyValueOf;
    /* Hash name to value hash mapping */
    mapping (bytes32 => bytes32) public propertyHashOf;

    /**
     * Insert new property value by name.
     * @notice If the same name exist value will be replaced.
     * @param _name name of property
     * @param _value property value
     */
    function insertProperty(string _name, string _value) onlyOwner {
        var nameHash = sha3(_name);
        // Check for inserting new property
        if (propertyHashOf[nameHash] == 0)
            propertyList.push(_name);

        // Store property value and value hash for future comparation
        propertyValueOf[nameHash] = _value;
        propertyHashOf[nameHash]  = sha3(_value);
    }

    /**
     * @dev Get property by name
     * @param _name property name
     */
    function getProperty(string _name) constant returns (string)
    { return propertyValueOf[sha3(_name)]; }

    /* Described object can be consist of some another objects */
    address[] public componentList;

    function componentLength() constant returns (uint)
    { return componentList.length; }

    function appendComponent(KObject _component) onlyOwner
    { componentList.push(_component); }
    
    function getComponent(uint _index) returns (KObject)
    { return KObject(componentList[_index]); }

    /**
     * Comparation function over knowledge objects describe equal object,
     * the equal objects has:
     * - equal properties
     * - equal components
     */
    function isEqual(Knowledge _to) constant returns (bool) {
        if (knowledgeType != _to.knowledgeType())
            return false; 

        KObject object = KObject(_to); 
        return isEqualProperties(object) && isEqualComponents(object);
    }

    function isEqualProperties(KObject _to) constant returns (bool) {
        // Count of properties in equal objects should be same
        if (propertyList.length != _to.propertyLength())
            return false;

        // Compare every property of objects
        for (uint i = 0; i < propertyList.length; ++i) {
            // Take a name of current property
            var nameHash = sha3(propertyList[i]);

            // Compare value of the same properties
            if (propertyHashOf[nameHash] != _to.propertyHashOf(nameHash))
                return false;
        }
        return true;
    }

    function isEqualComponents(KObject _to) constant returns (bool) {
        // Count of components in equal objects should be same
        if (componentList.length != _to.componentLength())
            return false;

        // Compare every components of objects
        for (uint i = 0; i < componentList.length; ++i) {
            var equalFound = false;

            for (uint j = 0; j < componentList.length; ++j)
                if (getComponent(i).isEqual(_to.getComponent(j))) {
                    equalFound = true;
                    break;
                }

            // Return false if no equal component found
            if (!equalFound)
                return false;
        }
        return true;
    }
}
