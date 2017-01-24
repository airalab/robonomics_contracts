pragma solidity ^0.4.4;
import 'lib/AddressMap.sol';
import 'common/Object.sol';

/**
 * @title The DAO core contract basicaly describe the organisation and contain:
 *          agent storage,
 *          infrastructure nodes,
 *          contract templates
 */
contract Core is Object {
    /* Short description */
    string  public name;
    string  public description;
    address public founder;

    /* Module manipulation events */
    event ModuleAdded(address indexed module);
    event ModuleRemoved(address indexed module);
    event ModuleReplaced(address indexed from, address indexed to);

    /* Modules map */
    AddressMap.Data modules;

    /* Module constant mapping */ 
    mapping(bytes32 => bool) is_constant;

    /**
     * @dev Contract ABI storage
     *      the contract interface contains source URI
     */
    mapping(address => string) public abiOf;


    /* Using libraries */
    using AddressList for AddressList.Data;
    using AddressMap for AddressMap.Data;
 
    /**
     * @dev DAO constructor
     * @param _name is a DAO name
     * @param _description is a short DAO description
     */
    function Core(string _name, string _description) {
        name         = _name;
        description  = _description;
        founder      = msg.sender;
    }

    /**
     * @dev Fast module exist check
     * @param _module is a module address
     * @return `true` wnen core contains module
     */
    function contains(address _module) constant returns (bool)
    { return modules.items.contains(_module); }

    /**
     * @dev Modules counter
     * @return count of modules in core
     */
    function size() constant returns (uint)
    { return modules.size(); }
 
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
    function get(string _name) constant returns (address)
    { return modules.get(_name); }

    /**
     * @dev Get module name by address
     * @param _module is a module address
     * @return module name
     */
    function getName(address _module) constant returns (string)
    { return modules.keyOf[_module]; }

    /**
     * @dev Get first module
     * @return first address
     */
    function first() constant returns (address)
    { return modules.items.head; }

    /**
     * @dev Get next module
     * @param _current is an current address
     * @return next address
     */
    function next(address _current) constant returns (address)
    { return modules.items.next(_current); }

    /**
     * @dev Set new module for given name
     * @param _name infrastructure node name
     * @param _module infrastructure node address
     * @param _abi node interface URI
     * @param _constant have a `true` value when you create permanent name of module
     */
    function set(string _name, address _module, string _abi, bool _constant) onlyOwner {
        if (isConstant(_name)) throw;

        // Notify
        if (modules.get(_name) != 0)
            ModuleReplaced(modules.get(_name), _module);
        else
            ModuleAdded(_module);
 
        // Set module in the map
        modules.set(_name, _module);

        // Register module abi
        abiOf[_module] = _abi;

        // Register constant flag 
        is_constant[sha3(_name)] = _constant;
    }
 
    /**
     * @dev Remove module by name
     * @param _name module name
     */
    function remove(string _name) onlyOwner {
        if (isConstant(_name)) throw;

        // Notify
        ModuleRemoved(modules.get(_name));

        // Remove module
        modules.remove(_name);
    }
}
