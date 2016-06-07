import 'lib/AddressMap.sol';
import 'common/Mortal.sol';

/**
 * @title The DAO core contract basicaly describe the organisation and contain:
 *          agent storage,
 *          infrastructure nodes,
 *          contract templates
 */
contract Core is Mortal {
    /* Short description */
    string  public name;
    string  public description;
    address public founder;

    /* Modules map */
    AddressMap.Data modules;

    /* Module constant mapping */ 
    mapping(bytes32 => bool) is_constant;

    /**
     * @dev Interface storage
     *      the contract interface contains source URI
     */
    mapping(address => string) public interfaceOf;


    /* Using libraries */
    using AddressList for AddressList.Data;
    using AddressMap for AddressMap.Data;
 
    /* DAO constructor */
    function Core(string _name, string _description) {
        name         = _name;
        description  = _description;
        founder      = msg.sender;
    }
 
    /**
     * @dev Check for module have permanent name
     * @param _name is a module name
     * @return `true` when module have permanent name
     */
    function isConstant(string _name) constant returns (bool)
    { return is_constant[sha3(_name)]; }

    /**
     * @dev Get module by name
     * @param _name is module name
     * @return module address
     */
    function getModule(string _name) constant returns (address)
    { return modules.get(_name); }

    /**
     * @dev Get module name by address
     * @param _module is a module address
     * @return module name
     */
    function getModuleName(address _module) constant returns (string)
    { return modules.keyOf[_module]; }

    /**
     * @dev Get first module
     * @return first address
     */
    function firstModule() constant returns (address)
    { return modules.items.head; }

    /**
     * @dev Get next module
     * @param _current is an current address
     * @return next address
     */
    function nextModule(address _current) constant returns (address)
    { return modules.items.next(_current); }

    /**
     * @dev Set new module for given name
     * @param _name infrastructure node name
     * @param _module infrastructure node address
     * @param _interface node interface URI
     * @param _constant have a `true` value when you create permanent name of module
     */
    function setModule(string _name, address _module, string _interface, bool _constant) onlyOwner {
        if (!isConstant(_name)) {
            // Set module in the map
            modules.set(_name, _module);

            // Register node interface
            interfaceOf[_module] = _interface;

            // Register constant module
            is_constant[sha3(_name)] = _constant;
        }
    }
 
    /**
     * @dev Remove module by name
     * @param _name module name
     */
    function removeModule(string _name) onlyOwner
    { modules.remove(_name); }
}
