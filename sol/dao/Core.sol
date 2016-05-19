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

    /* Templates map */
    AddressMap.Data templates;

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
     * @dev Get module by name
     * @param _name is module name
     * @return module address
     */
    function getModule(string _name) constant returns (address)
    { return modules.get(_name); }

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
     * @dev Get template by name
     * @param _name is template name
     * @return template address
     */
    function getTemplate(string _name) constant returns (address)
    { return templates.get(_name); }

    /**
     * @dev Get first template
     * @return first address
     */
    function firstTemplate() constant returns (address)
    { return templates.items.head; }

    /**
     * @dev Get next template
     * @param _current is an current address
     * @return next address
     */
    function nextTemplate(address _current) constant returns (address)
    { return templates.items.next(_current); }
 
    /**
     * @dev Interface storage
     *      the contract interface contains source URI
     */
    mapping(address => string) public interfaceOf;

    /**
     * @dev Set new module for given name
     * @param _name infrastructure node name
     * @param _module infrastructure node address
     * @param _interface node interface URI
     */
    function setModule(string _name, address _module, string _interface) onlyOwner {
        // Set module in the map
        modules.set(_name, _module);

        // Register node interface
        interfaceOf[_module] = _interface;
    }
 
    /**
     * @dev Remove module by name
     * @param _name module name
     */
    function removeModule(string _name) onlyOwner
    { modules.remove(_name); }
 
    /**
     * @dev Set new template for given name
     * @param _name infrastructure node name
     * @param _template infrastructure node address
     */
    function setTemplate(string _name, address _template) onlyOwner
    { templates.set(_name, _template); }
    
    /**
     * @dev Remove template by name
     * @param _name template name
     */
    function removeTemplate(string _name) onlyOwner
    { templates.remove(_name); }
}
