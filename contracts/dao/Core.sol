pragma solidity ^0.4.4;
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
    address[] public modules;
    mapping(bytes32 => uint256) public indexOf;
    mapping(address => string)  public getName;

    /* Module constant mapping */ 
    mapping(bytes32 => bool) is_constant;

    /**
     * @dev Contract ABI storage
     *      the contract interface contains source URI
     */
    mapping(address => string) public abiOf;

    /**
     * @dev DAO constructor
     * @param _name is a DAO name
     * @param _description is a short DAO description
     */
    function Core(string _name, string _description) {
        name         = _name;
        description  = _description;
        founder      = msg.sender;
        modules.push(0);
    }

    /**
     * @dev Fast module exist check
     * @param _module is a module address
     * @return `true` wnen core contains module
     */
    function contains(address _module) constant returns (bool)
    { return indexOf[sha3(getName[_module])] != 0; }

    /**
     * @dev Modules counter
     * @return count of modules in core
     */
    function size() constant returns (uint)
    { return modules.length - 1; }
 
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
    { return modules[indexOf[sha3(_name)]]; }

    /**
     * @dev Get first module
     * @return first address
     */
    function first() constant returns (address)
    { return modules[1]; }

    /**
     * @dev Get next module
     * @param _current is an current address
     * @return next address
     */
    function next(address _current) constant returns (address)
    { return modules[indexOf[sha3(getName[_current])] + 1]; }

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
        var replace = indexOf[sha3(_name)];
        if (replace != 0) {
            ModuleReplaced(modules[replace], _module);
            getName[modules[replace]] = _name;
            indexOf[sha3(_name)] = replace;
            modules[replace] = _module;
        } else {
            ModuleAdded(_module);
            indexOf[sha3(_name)] = modules.length;
            getName[_module] = _name;
            modules.push(_module);
        }
 
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

        var index = indexOf[sha3(_name)];
        if (index > 0 && index < modules.length) {
            if (index < modules.length - 1) {
                var last = modules[modules.length - 1];
                modules[index] = last;
                indexOf[sha3(getName[last])] = index;
            }

            --modules.length;
            indexOf[sha3(_name)] = 0;

            // Notify
            ModuleRemoved(modules[index]);
        } else throw;
    }
}
