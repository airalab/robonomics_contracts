import 'lib/AddressArray.sol';
import 'common/Mortal.sol';

/**
 * @title The DAO core contract basicaly describe the organisation and contain:
 *          agent storage,
 *          infrastructure nodes,
 *          contract templates
 */
contract Core is Mortal {
    /* DAO configuration */
    struct Config {
        /* Short description */
        string  name;
        string  description;
        address founder;

        /* DAO nodes */
        address[] nodes;
        mapping (bytes32 => address) getNodeBy;
        mapping (address => string)  getNodeNameBy;
        
        /* DAO templates */
        address[] templates;
        mapping (bytes32 => address) getTemplateBy;
        mapping (address => string)  getTemplateNameBy;
    }

    Config dao;

    /* Public getters */
    function getName() constant returns (string)
    { return dao.name; }

    function getDescription() constant returns (string)
    { return dao.description; }

    function getFounder() constant returns (address)
    { return dao.founder; }

    function getNodeLength() constant returns (uint)
    { return dao.nodes.length; }

    function getNodeByIndex(uint _index) constant returns (address)
    { return dao.nodes[_index]; }

    function getNode(string _name) constant returns (address)
    { return dao.getNodeBy[sha3(_name)]; }

    function getNodeName(address _node) constant returns (string)
    { return dao.getNodeNameBy[_node]; }

    function getTemplateLength() constant returns (uint)
    { return dao.templates.length; }

    function getTemplateByIndex(uint _index) constant returns (address)
    { return dao.templates[_index]; }

    function getTemplate(string _name) constant returns (address)
    { return dao.getTemplateBy[sha3(_name)]; }

    function getTemplateName(address _node) constant returns (string)
    { return dao.getTemplateNameBy[_node]; }

    /**
     * @dev Interface storage
     *      the contract interface contains source URI
     */
    mapping(address => string) public interfaceOf;

    /* DAO constructor */
    function Core(string _name, string _description) {
        dao.name         = _name;
        dao.description  = _description;
        dao.founder      = msg.sender;
    }

    /* Using the AddressArray library */
    using AddressArray for address[];

    /** 
     * @dev DAO nodes setter
     * @notice set new node for given name, replaced address will returned
     * @param _name infrastructure node name
     * @param _node infrastructure node address
     * @param _interface node interface URI
     */
    function setNode(string _name, address _node, string _interface) onlyOwner
            returns (address) {
        // Remove node if replaced
        var replaced = getNode(_name);
        if (replaced != 0)
            removeNode(replaced);
        // Append new node
        dao.nodes.push(_node);
        dao.getNodeBy[sha3(_name)] = _node;
        dao.getNodeNameBy[_node]   = _name;
        // Register node interface
        interfaceOf[_node] = _interface;
        // Return replaced address
        return replaced;
    }
    
    /**
     * @dev Remove node by name
     * @param _name node name
     * @return removed node address
     */
    function removeNode(string _name) onlyOwner returns (address) {
        var removed = getNode(_name);
        removeNode(removed);
        return removed;
    }
    
    /**
     * @dev Remove node by address
     * @param _node target node address
     */
    function removeNode(address _node) onlyOwner {
        var index = dao.nodes.indexOf(_node);
        if (index < dao.nodes.length)
            dao.nodes.remove(index);
    }
 
    /**
     * @dev DAO templates setter
     * @notice set new template for given name, replaced address will returned
     * @param _name contract template name
     * @param _template contract template address
     * @param _interface contract template interface URI
     */
    function setTemplate(string _name, address _template, string _interface) onlyOwner
            returns (address) {
        // Remove template if replaced
        var replaced = getTemplate(_name);
        if (replaced != 0)
            removeTemplate(replaced);
        // Append new template
        dao.templates.push(_template);
        dao.getTemplateBy[sha3(_name)]   = _template;
        dao.getTemplateNameBy[_template] = _name;
        // Register template interface
        interfaceOf[_template] = _interface;
        // Return replaced address
        return replaced;
    }
 
    /**
     * @dev Remove template by name
     * @param _name template name
     * @return removed template address
     */
    function removeTemplate(string _name) onlyOwner returns (address) {
        var removed = getTemplate(_name);
        removeTemplate(removed);
        return removed;
    }

    /**
     * @dev Remove template by address
     * @param _template target template address
     */
    function removeTemplate(address _template) onlyOwner {
        var index = dao.templates.indexOf(_template);
        if (index < dao.templates.length)
            dao.templates.remove(index);
    }
}
