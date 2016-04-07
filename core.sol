import 'agent_storage.sol';

contract Core is Mortal {
    /* DAO configuration */
    struct Config {
        /* Short description */
        string  name;
        string  description;
        address founder;

        /* DAO knowledge and active contracts storage */
        AgentStorage agentStorage;

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

    function getStorage() constant returns (AgentStorage)
    { return dao.agentStorage; }

    function getNodeLength() constant returns (uint)
    { return dao.nodes.length; }

    function getNode(uint _index) constant returns (address)
    { return dao.nodes[_index]; }

    function getNode(string _name) constant returns (address)
    { return dao.getNodeBy[sha3(_name)]; }

    function getNodeName(address _node) constant returns (string)
    { return dao.getNodeNameBy[_node]; }

    function getTemplateLength() constant returns (uint)
    { return dao.templates.length; }

    function getTemplate(uint _index) constant returns (address)
    { return dao.templates[_index]; }

    function getTemplate(string _name) constant returns (address)
    { return dao.getTemplateBy[sha3(_name)]; }

    function getTemplateName(address _node) constant returns (string)
    { return dao.getTemplateNameBy[_node]; }

    /*
     * Interface storage
     *   the contract interface contains GitHub source URI
     */
    mapping (address => string) public interfaceOf;

    /* DAO constructor */
    function Core(string _name, string _description) {
        dao.name         = _name;
        dao.description  = _description;
        dao.founder      = msg.sender;
        dao.agentStorage = new AgentStorage();
    }

    /* Using the AddressArray library */
    using AddressArray for address[];

    /* 
     * DAO nodes setter
     *   set new node for given name, replaced address will returned
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
    
    function removeNode(string _name) onlyOwner returns (address) {
        var removed = getNode(_name);
        removeNode(removed);
        return removed;
    }
    
    function removeNode(address _node) onlyOwner {
        var index = dao.nodes.indexOf(_node);
        if (index < dao.nodes.length)
            dao.nodes.remove(index);
    }
    
    /*
     * DAO templates setter
     *   set new template for given name, replaced address will returned
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
    
    function removeTemplate(string _name) onlyOwner returns (address) {
        var removed = getTemplate(_name);
        removeTemplate(removed);
        return removed;
    }
    
    function removeTemplate(address _node) onlyOwner {
        var index = dao.templates.indexOf(_node);
        if (index < dao.templates.length)
            dao.templates.remove(index);
    }
}
