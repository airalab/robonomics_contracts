pragma solidity ^0.4.2;
import 'common/Mortal.sol';
import 'lib/AddressList.sol';
import 'creator/CreatorSupplyChain.sol';

contract TokenSupplyChain is Mortal {
    /**
     * @dev Triggered whenever `transfer` or `transferFrom` is called.
     */
    event Transfer(address indexed _from,
                   address indexed _to,
                   address indexed _chain);

    /**
     * @dev Triggered whenever `approve` is called.
     */
    event Approval(address indexed _owner,
                   address indexed _spender,
                   address indexed _chain);

    /**
     * @dev Triggered whenever `fork` is called.
     */
    event ChainFork(address indexed _parent,
                    address indexed _first,
                    address indexed _second);
    /**
     * @dev Triggered whenever `merge` is called.
     */
    event ChainMerge(address indexed _first,
                     address indexed _second,
                     address indexed _child);
 
    /* Short description of token */
    string public name;
    string public symbol;

    /* Total count of tokens exist */
    uint public totalSupply;

    /* Fixed point position */
    uint8 public decimals;

    /* Valid chain tracking */
    AddressList.Data totalBalance;
    mapping(address => AddressList.Data) balanceOf;
    mapping(address => mapping(address => AddressList.Data)) allowanceOf;

    /* Use libraries */
    using AddressList for AddressList.Data;

    function TokenSupplyChain(string _name, string _symbol, uint8 _decimals) {
        name        = _name;
        symbol      = _symbol;
        decimals    = _decimals;
    }

    function emission(uint _value) onlyOwner returns (bool) {
        address[] memory noparent;
        var chain = CreatorSupplyChain.create(noparent, _value);
        totalBalance.append(chain);
        balanceOf[owner].append(chain);
        totalSupply += _value;
        return true;
    }

    function burn(SupplyChain _chain) {
        if (balanceOf[msg.sender].isContain[_chain]) {
            totalBalance.remove(_chain);
            balanceOf[msg.sender].remove(_chain);
            totalSupply -= _chain.value();
        } else throw;
    }

    /**
     * @dev Chain validation
     * @param _chain is a supply chain item
     * @return true when chain on token balance
     */
    function isValid(address _chain) constant returns (bool)
    { return totalBalance.isContain[_chain]; }

    /**
     * @dev Take a first supply chain 
     * @return first supply chain address
     */
    function first() constant returns (SupplyChain)
    { return SupplyChain(totalBalance.first()); }
    
    /**
     * @dev Take a next supply chain 
     * @param _current is a current step
     * @return next supply chain address
     */
    function next(address _current) constant returns (SupplyChain)
    { return SupplyChain(totalBalance.next(_current)); }

    /**
     * @dev Account balance validation
     * @param _account is any account address
     * @param _chain is supply chain item
     * @return true when chain on account balance
     */
    function onBalance(address _account, address _chain) constant returns (bool)
    { return balanceOf[_account].isContain[_chain]; }

    /**
     * @dev Take a first supply chain from balance
     * @param _account is any account address
     * @return supply chain address
     */
    function balanceFirst(address _account) constant returns (SupplyChain)
    { return SupplyChain(balanceOf[_account].first()); }
    
    /**
     * @dev Take a next supply chain from balance
     * @param _account is any account address
     * @param _current is a current item of iteration
     * @return supply chain address
     */
    function balanceNext(address _account, address _current) constant returns (SupplyChain)
    { return SupplyChain(balanceOf[_account].next(_current)); }

    /**
     * @dev Allowance validation
     * @param _from is a source address
     * @param _to is a destination address
     * @param _chain is a supply chain item
     * @return true when chain approved
     */
    function allowance(address _from, address _to, address _chain) constant returns (bool) 
    { return allowanceOf[_from][_to].isContain[_chain]; }

    /**
     * @dev Transfer chain and log transaction
     * @param _to is a destination address
     * @param _chain is a supply chain item
     * @param _comment is a string transaction comment
     * @return true when all done
     */
    function transfer(address _to, SupplyChain _chain, string _comment) returns (bool) {
        if (balanceOf[msg.sender].isContain[_chain]) {
            if (_chain.txPush(_comment)) {
                balanceOf[msg.sender].remove(_chain);
                balanceOf[_to].append(_chain);

                if (!balanceOf[msg.sender].isContain[_chain] &&
                    balanceOf[_to].isContain[_chain]) throw;

                Transfer(msg.sender, _to, _chain);
                return true;
            }
        }
        return false;
    }

    /**
     * @dev Transfer chain and log transaction
     * @param _to is a destination address
     * @param _chain is a supply chain item
     * @param _comment is a string transaction comment
     * @return true when all done
     */
    function transferFrom(address _from, address _to,
                          SupplyChain _chain, string _comment) returns (bool) {
        if (allowanceOf[_from][msg.sender].isContain[_chain]) {
            if (_chain.txPush(_comment)) {
                balanceOf[_from].remove(_chain);
                balanceOf[_to].append(_chain);

                if (!balanceOf[_from].isContain[_chain] &&
                    balanceOf[_to].isContain[_chain]) throw;
                
                Transfer(_from, _to, _chain);
                return true;
            }
        }
        return false;
    }

    /**
     * @dev Approve transfer chain
     * @param _to is a destination address
     * @param _chain is a supply chain
     * @return true when all done
     */
    function approve(address _to, address _chain) returns (bool) {
        if (balanceOf[msg.sender].isContain[_chain]) {
            allowanceOf[msg.sender][_to].append(_chain);
            if (allowanceOf[msg.sender][_to].isContain[_chain]) {
                Approval(msg.sender, _to, _chain);
                return true;
            }
        }
        return false;
    }

    /**
     * @dev Fork supply chain
     * @param _chain is a supply chain item
     * @param _value is a forked value
     * @return pair of chains
     */
    function fork(SupplyChain _chain, uint _value) returns (SupplyChain, SupplyChain) {
        var senderBalance = balanceOf[msg.sender];

        if (!senderBalance.isContain[_chain]
          || _value >= _chain.value()) throw; 

        totalBalance.remove(_chain);
        senderBalance.remove(_chain);

        // Paranoid check
        if (totalBalance.isContain[_chain]
          || senderBalance.isContain[_chain]) throw;

        uint residual = _chain.value() - _value;
        address[] memory parent = new address[](1);
        parent[0] = _chain;
        var first  = CreatorSupplyChain.create(parent, residual);
        var second = CreatorSupplyChain.create(parent, _value);

        totalBalance.append(first);
        totalBalance.append(second);
        senderBalance.append(first);
        senderBalance.append(second);
        
        // Paranoid check
        if ( !totalBalance.isContain[first]
          || !totalBalance.isContain[second]
          || !senderBalance.isContain[first]
          || !senderBalance.isContain[second]) throw;

        ChainFork(_chain, first, second);
        return (first, second);
    }

    /**
     * @dev Merge supply chains
     * @param _first is a supply chain item
     * @param _second is a supply chain item
     * @return supply chain item
     */
    function merge(SupplyChain _first, SupplyChain _second) returns (SupplyChain) {
        var senderBalance = balanceOf[msg.sender];

        if ( !senderBalance.isContain[_first]
          || !senderBalance.isContain[_second]) throw;
        
        totalBalance.remove(_first);
        totalBalance.remove(_second);
        senderBalance.remove(_first);
        senderBalance.remove(_second);
        
        // Paranoid check
        if ( totalBalance.isContain[_first]
          || totalBalance.isContain[_second]
          || senderBalance.isContain[_first]
          || senderBalance.isContain[_second]) throw;
        
        uint value = _first.value() + _second.value();
        address[] memory parent = new address[](2);
        parent[0] = _first; parent[1] = _second;
        var chain = CreatorSupplyChain.create(parent, value);
        
        totalBalance.append(chain);
        senderBalance.append(chain);
        
        // Paranoid check
        if ( !totalBalance.isContain[chain]
          || !senderBalance.isContain[chain]) throw;

        ChainMerge(_first, _second, chain);
        return chain;
    }
}
