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
        Array.Data nodes;
        mapping (bytes32 => address) getNodeBy;
        mapping (address => string)  getNodeNameBy;
 
        /* DAO templates */
        Array.Data templates;
        mapping (bytes32 => address) getTemplateBy;
        mapping (address => string)  getTemplateNameBy;
    }

    Config dao;

    /* Public getters */
    function getName() returns (string)
    { return dao.name; }

    function getDescription() returns (string)
    { return dao.description; }

    function getFounder() returns (address)
    { return dao.founder; }

    function getStorage() returns (AgentStorage)
    { return dao.agentStorage; }

    function getNodeLength() returns (uint)
    { return Array.size(dao.nodes); }

    function getNode(uint _index) returns (address)
    { return Array.get(dao.nodes, _index); }

    function getNode(string _name) returns (address)
    { return dao.getNodeBy[sha3(_name)]; }

    function getNodeName(address _node) returns (string)
    { return dao.getNodeNameBy[_node]; }

    function getTemplateLength() returns (uint)
    { return Array.size(dao.templates); }

    function getTemplate(uint _index) returns (address)
    { return Array.get(dao.templates, _index); }

    function getTemplate(string _name) returns (address)
    { return dao.getTemplateBy[sha3(_name)]; }

    function getTemplateName(address _node) returns (string)
    { return dao.getTemplateNameBy[_node]; }

    /*
     * Interface storage
     *   the contract interface contains GitHub source URI
     */
    mapping (address => string) public interfaceOf;
 
    /* Common used array data iterator */
    Array.Iterator it;

    /* DAO constructor */
    function Core(string _name, string _description) {
        dao.name         = _name;
        dao.description  = _description;
        dao.founder      = msg.sender;
        dao.agentStorage = new AgentStorage();
    }

    /* Change DAO owner */
    function setAdmin(address _admin) onlyOwner
    { owner = _admin; }

    /* 
     * DAO nodes setter
     *   set new node for given name, replaced address will returned
     */
    function setNode(string _name, address _node, string _interface) onlyOwner
            returns (address) {
        // Remove node if replaced
        var replaced = getNode(_name);
        if (replaced != 0) {
            Array.setBegin(dao.nodes, it);
            Array.find(it, getNode(_name));
            Array.remove(it);
        }
        // Append new node
        Array.append(dao.nodes, _node);
        dao.getNodeBy[sha3(_name)] = _node;
        dao.getNodeNameBy[_node]   = _name;
        // Register node interface
        interfaceOf[_node] = _interface;
        // Return replaced address
        return replaced;
    }
 
    /*
     * DAO templates setter
     *   set new template for given name, replaced address will returned
     */
    function setTemplate(string _name, address _template, string _interface) onlyOwner
            returns (address) {
        // Remove template if replaced
        var replaced = getTemplate(_name);
        if (replaced != 0) {
            Array.setBegin(dao.templates, it);
            Array.find(it, getNode(_name));
            Array.remove(it);
        }
        // Append new template
        Array.append(dao.templates, _template);
        dao.getNodeBy[sha3(_name)]   = _template;
        dao.getNodeNameBy[_template] = _name;
        // Register template interface
        interfaceOf[_template] = _interface;
        // Return replaced address
        return replaced;
    }
}
