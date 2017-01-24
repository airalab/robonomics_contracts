pragma solidity ^0.4.4;
import 'common/Object.sol';

contract TokenSupplyChain is Object {
    /**
     * @dev Triggered whenever `transfer` or `transferFrom` is called.
     */
    event Transfer(address indexed _from,
                   address indexed _to,
                   uint    indexed _chain_id);

    /**
     * @dev Triggered whenever `approve` is called.
     */
    event Approval(address indexed _owner,
                   address indexed _spender,
                   uint    indexed _chain_id);

    /**
     * @dev Triggered whenever `fork` is called.
     */
    event ChainFork(uint indexed _parent,
                    uint indexed _first,
                    uint indexed _second);
    /**
     * @dev Triggered whenever `merge` is called.
     */
    event ChainMerge(uint indexed _first,
                     uint indexed _second,
                     uint indexed _child);
 
    /* Short description of token */
    string public name;
    string public symbol;

    /* Total count of tokens exist */
    uint public totalSupply;

    /* Fixed point position */
    uint8 public decimals;

    /* Transaction */
    struct Tx {
        string  comment;
        uint    stamp;
        address from;
        address to;
    }

    /* Linear transaction chain */
    struct TxChain {
        uint[] parent_id;
        uint   value;
        Tx[]   txs;
    }

    /* Transaction graph */
    TxChain[] graph;
    
    /**
     * @dev Take transaction chain value
     * @param _chain_id is a supply chain id
     * @return chain value
     */
    function txChainValue(uint _chain_id) constant returns (uint)
    { return graph[_chain_id].value; }
    
    /**
     * @dev Take transaction chain parent id list
     * @param _chain_id is a supply chain id
     * @return chain parent id list
     */
    function txChainParent(uint _chain_id) constant returns (uint[])
    { return graph[_chain_id].parent_id; }

    /**
     * @dev Take transaction info
     * @param _chain_id is supply chain id
     * @param _tx_id is transaction id
     * @return transaction info: comment, time stamp, source, destination
     */
    function txAt(uint _chain_id, uint _tx_id) constant
        returns (string, uint, address, address)
    {
        var t = graph[_chain_id].txs[_tx_id];
        return (t.comment, t.stamp, t.from, t.to);
    }

    mapping(uint => bool)                       public isValid; 
    mapping(uint => address)                    public holder;
    mapping(address => mapping(uint => bool))   public onBalance;
    mapping(address =>
            mapping(address =>
                    mapping(uint => bool)))     public allowance;

    function TokenSupplyChain(string _name, string _symbol, uint8 _decimals) {
        name        = _name;
        symbol      = _symbol;
        decimals    = _decimals;
    }

    /**
     * @dev Make a new chain
     * @param _value is a chain value
     * @return true when all done
     */
    function emission(uint _value) onlyOwner returns (bool) {
        var chain_id = graph.length++;
        graph[chain_id].value = _value;

        isValid[chain_id] = true;
        holder[chain_id]  = owner;
        onBalance[owner][chain_id] = true;
        totalSupply += graph[chain_id].value;
        return true;
    }

    /**
     * @dev Burn the chain
     * @param _chain_id is a supply chain id
     * @return true when all done
     */
    function burn(uint _chain_id) returns (bool) {
        if (onBalance[msg.sender][_chain_id]) {
            isValid[_chain_id] = false;
            holder[_chain_id]  = 0;
            onBalance[msg.sender][_chain_id] = false;
            totalSupply -= graph[_chain_id].value;
            return true;
        }
        return false;
    }

    /**
     * @dev Transfer chain and log transaction
     * @param _to is a destination address
     * @param _chain_id is a supply chain id
     * @param _comment is a string transaction comment
     * @return true when all done
     */
    function transfer(address _to, uint _chain_id, string _comment) returns (bool) {
        if (onBalance[msg.sender][_chain_id]) {
            // Push transaction
            graph[_chain_id].txs.push(
                Tx({comment: _comment, stamp: now, from: msg.sender, to: _to}));

            // Change chain holder
            onBalance[msg.sender][_chain_id] = false;
            onBalance[_to][_chain_id]        = true;
            holder[_chain_id]                = _to;

            // Event
            Transfer(msg.sender, _to, _chain_id);
            return true;
        }
        return false;
    }

    /**
     * @dev Transfer chain and log transaction
     * @param _to is a destination address
     * @param _chain_id is a supply chain id
     * @param _comment is a string transaction comment
     * @return true when all done
     */
    function transferFrom(address _from, address _to,
                          uint _chain_id, string _comment) returns (bool) {
        if (allowance[_from][msg.sender][_chain_id]
            && onBalance[_from][_chain_id]) {
            // Push transaction
            graph[_chain_id].txs.push(
                Tx({comment: _comment, stamp: now, from: msg.sender, to: _to}));

            // Chainge holder
            onBalance[_from][_chain_id] = false;
            onBalance[_to][_chain_id]   = true;
            holder[_chain_id]           = _to;

            // Event
            Transfer(_from, _to, _chain_id);
            return true;
        }
        return false;
    }

    /**
     * @dev Approve transfer chain
     * @param _to is a destination address
     * @param _chain_id is a supply chain
     * @return true when all done
     */
    function approve(address _to, uint _chain_id) returns (bool) {
        allowance[msg.sender][_to][_chain_id] = true; 
        return allowance[msg.sender][_to][_chain_id];
    }

    /**
     * @dev Fork supply chain
     * @param _chain_id is a supply chain item
     * @param _value is a forked value
     * @return pair of chains
     */
    function fork(uint _chain_id, uint _value) returns (uint, uint) {
        var chain = graph[_chain_id];
        if (!onBalance[msg.sender][_chain_id]
            || chain.value <= _value) throw;

        // Drop chain from token
        holder[_chain_id]  = 0;
        isValid[_chain_id] = false;
        onBalance[msg.sender][_chain_id] = false;

        // Fork
        var residue = chain.value - _value; 
        var first_id = graph.length++;
        graph[first_id].parent_id = [_chain_id];
        graph[first_id].value     = residue;

        holder[first_id]  = msg.sender;
        isValid[first_id] = true;
        onBalance[msg.sender][first_id] = true;
        
        var second_id = graph.length++;
        graph[second_id].parent_id = [_chain_id];
        graph[second_id].value     = _value;
 
        holder[second_id]  = msg.sender;
        isValid[second_id] = true;
        onBalance[msg.sender][second_id] = true;

        ChainFork(_chain_id, first_id, second_id);
        return (first_id, second_id);
    }

    /**
     * @dev Merge supply chains
     * @param _first_id is a supply chain item
     * @param _second_id is a supply chain item
     * @return supply chain item
     */
    function merge(uint _first_id, uint _second_id) returns (uint) {
        if (!onBalance[msg.sender][_first_id]
            || !onBalance[msg.sender][_second_id]) throw;
        
        // Drop chains
        var first  = graph[_first_id];
        var second = graph[_second_id];
        
        holder[_first_id]  = 0;
        isValid[_first_id] = false;
        onBalance[msg.sender][_first_id] = false;
        
        holder[_second_id]  = 0;
        isValid[_second_id] = false;
        onBalance[msg.sender][_second_id] = false;

        // Merge
        var chain_id = graph.length++;
        graph[chain_id].parent_id = [_first_id, _second_id];
        graph[chain_id].value     = first.value + second.value;
        
        holder[chain_id]  = msg.sender;
        isValid[chain_id] = true;
        onBalance[msg.sender][chain_id] = true;

        ChainMerge(_first_id, _second_id, chain_id);
        return chain_id;
    }
}
