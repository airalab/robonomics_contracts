/*
 * Interface for object comparation 
 */
contract Comparable {
   function isEqual(Comparable _to) returns (bool);
}

/*
 * Contract for objects that can be morder
 */
contract Mortal {
    /* Contract owner address */
    address public owner;

    /* Store owner on creation */
    function Mortal() { owner = msg.sender; }

    /* Only owner can kill me */
    function kill() {
        if (msg.sender == owner) suicide(this);
    }
}

/*
 * Knowledge is a generic declaration of object or process 
 */
contract Knowledge is Comparable, Mortal {
    /* Knowledge can have a type described below */
    int public OBJECT  = 1;
    int public PROCESS = 2;
    /* Knowledge type is a int value */
    int public knowledgeType;
    
    /* Constructor gets the type as argument */
    function Knowledge(int _type) { knowledgeType = _type; }

    /* Generic Knowledge comparation procedure */
    function isEqual(Knowledge _to) returns (bool) {
        // Knowledge with different types can't be equal
        if (_to.knowledgeType() != knowledgeType)
            return false;
        /*
         * Knowledge with the same type can be compared,
         * comparation procedure implemented in the inherit types
         */
        if (knowledgeType == OBJECT) {
            return KObject(this).isEqual(KObject(_to));
        } else {
            return KProcess(this).isEqual(KProcess(_to));
        }
    }
}

contract KObject is Knowledge(Knowledge.OBJECT) {

    /* Property describe attribute of presented object */
    struct Property {
        string name;
        string value;
    }
    /* List of object properties */
    Property[] public properties;
    /* Name to value mapping */
    mapping (string => string) propertyValueOf;

    /* Described object can be consist of some another objects */
    KObject[] public components;

    /*
     * The equal objects has:
     *  - equal properties
     *  - equal components
     */
    function isEqual(KObject _to) returns (bool) {
        return isEqualProperties(_to) && isEqualComponents(_to);
    }

    function isEqualProperties(KObject _to) returns (bool) {
        // Count of properties in equal objects should be same
        if (properties.length != _to.properties.length)
            return false;
        
        // Compare every property of objects
        for (var i = 0; i < properties.length; ++i) {
            // Take a name of current property
            var name = properties[i].name;

            // Compare value of the same properties
            if (propertyValueOf[name] != _to.propertyValueOf[name])
                return false;
        }
        return true;
    }

    function isEqualComponents(KObject _to) returns (bool) {
        // Count of components in equal objects should be same
        if (components.length != _to.components.length)
            return false;

        // Compare every components of objects
        for (var i = 0; i < components.length; ++i) {
            var equalFound = false;

            for (var j = 0; j < _to.components.length; ++j)
                equalFound |= components[i].isEqual(_to.components[j]);

            // Return false if no equal component found
            if (!equalFound)
                return false;
        }
        return true;
    }
}

contract KProcess is Knowledge(Knowledge.PROCESS) {
    /*
     * Morphism describe knowledge manipulation line
     * e.g. apple production have a morphism with 
     * three objects: Ground -> AppleTree -> Apple
     * this knowledges can be stored in morphism list
     * as [ Ground, AppleTree, Apple ]
     */
    Knowledge[] morphism;

    function append(Knowledge _knowledge) {
        morphism[morphism.length++] = _knowledge;
    }

    function isEqual(KProcess _to) {
        // Count of knowledges in equal processes should be same
        if (morphism.length != _to.morphism.length)
            return false;

        for (var i = 0; i < morphism.length; ++i)
            // All knowledge in morphism line should be equal
            if (!morphism[i].isEqual(_to.morphism[i]))
                return false;
        return true;
    }
}

contract KnowledgeIndex {
    /* Available knowledge names */ 
    string[] public thesaurus;
    
    /* Mapping to knowledge from name */
    mapping (string => Knowledge) knowledgeOf;

    /*
     * Insert knowledge by name
     *   knowledge instance with the same name will be replaced
     */
    function insert(string _name, Knowledge _knowledge) {
        knowledgeOf[_name] = _knowledge;

        // Check when thesaurus already contains name
        if (!thesaurusCheck(_name))
            thesaurus[thesaurus.length++] = _name;
    }

    function thesaurusCheck(string _name) {
        for (var i = 0; i < thesaurus.length; ++i)
            if (thesaurus[i] == _name)
                return true;
        return false;
    }
}
