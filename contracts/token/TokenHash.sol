pragma solidity ^0.4.4;
import 'common/Object.sol';
import './ERC20.sol';

/**
 * @title Token compatible contract represents any asset in digital economy
 * @dev Accounting based on sha3 hashed identifiers
 */
contract TokenHash is Object, ERC20 {
    /* Short description of token */
    string public name;
    string public symbol;

    /* Fixed point position */
    uint8 public decimals;

    /* Token approvement system */
    mapping(bytes32 => uint256) balances;
    mapping(bytes32 => mapping(bytes32 => uint256)) allowances;
 
    /**
     * @dev Get balance of plain address
     * @param _owner is a target address
     * @return amount of tokens on balance
     */
    function balanceOf(address _owner) constant returns (uint256)
    { return balances[sha3(_owner)]; }

    /**
     * @dev Get balance of ident
     * @param _owner is a target ident
     * @return amount of tokens on balance
     */
    function balanceOf(bytes32 _owner) constant returns (uint256)
    { return balances[_owner]; }

    /**
     * @dev Take allowed tokens
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(address _owner, address _spender) constant returns (uint256)
    { return allowances[sha3(_owner)][sha3(_spender)]; }

    /**
     * @dev Take allowed tokens
     * @param _owner The ident of the account owning tokens
     * @param _spender The ident of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(bytes32 _owner, bytes32 _spender) constant returns (uint256)
    { return allowances[_owner][_spender]; }

    /* Token constructor */
    function TokenHash(string _name, string _symbol, uint8 _decimals, uint256 _count) {
        name        = _name;
        symbol      = _symbol;
        decimals    = _decimals;
        totalSupply = _count;
        balances[sha3(msg.sender)] = _count;
    }
 
    /**
     * @dev Transfer self tokens to given address
     * @param _to destination address
     * @param _value amount of token values to send
     * @notice `_value` tokens will be sended to `_to`
     * @return `true` when transfer done
     */
    function transfer(address _to, uint256 _value) returns (bool) {
        var sender = sha3(msg.sender);

        if (balances[sender] >= _value) {
            balances[sender]    -= _value;
            balances[sha3(_to)] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    /**
     * @dev Transfer self tokens to given address
     * @param _to destination ident
     * @param _value amount of token values to send
     * @notice `_value` tokens will be sended to `_to`
     * @return `true` when transfer done
     */
    function transfer(bytes32 _to, uint256 _value) returns (bool) {
        var sender = sha3(msg.sender);

        if (balances[sender] >= _value) {
            balances[sender] -= _value;
            balances[_to]    += _value;
            TransferHash(sender, _to, _value);
            return true;
        }
        return false;
    }


    /**
     * @dev Transfer with approvement mechainsm
     * @param _from source address, `_value` tokens shold be approved for `sender`
     * @param _to destination address
     * @param _value amount of token values to send 
     * @notice from `_from` will be sended `_value` tokens to `_to`
     * @return `true` when transfer is done
     */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        var to    = sha3(_to);
        var from  = sha3(_from);
        var sender= sha3(msg.sender);
        var avail = allowances[from][sender]
                  > balances[from] ? balances[from]
                                   : allowances[from][sender];
        if (avail >= _value) {
            allowances[from][sender] -= _value;
            balances[from] -= _value;
            balances[to]   += _value;
            Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    /**
     * @dev Transfer with approvement mechainsm
     * @param _from source ident, `_value` tokens shold be approved for `sender`
     * @param _to destination ident
     * @param _value amount of token values to send 
     * @notice from `_from` will be sended `_value` tokens to `_to`
     * @return `true` when transfer is done
     */
    function transferFrom(bytes32 _from, bytes32 _to, uint256 _value) returns (bool) {
        var sender= sha3(msg.sender);
        var avail = allowances[_from][sender]
                  > balances[_from] ? balances[_from]
                                    : allowances[_from][sender];
        if (avail >= _value) {
            allowances[_from][sender] -= _value;
            balances[_from] -= _value;
            balances[_to]   += _value;
            TransferHash(_from, _to, _value);
            return true;
        }
        return false;
    }

    /**
     * @dev Give to target address ability for self token manipulation without sending
     * @param _spender target address (future requester)
     * @param _value amount of token values for approving
     */
    function approve(address _spender, uint256 _value) returns (bool) {
        allowances[sha3(msg.sender)][sha3(_spender)] += _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
 
    /**
     * @dev Give to target ident ability for self token manipulation without sending
     * @param _spender target ident (future requester)
     * @param _value amount of token values for approving
     */
    function approve(bytes32 _spender, uint256 _value) returns (bool) {
        allowances[sha3(msg.sender)][_spender] += _value;
        ApprovalHash(sha3(msg.sender), _spender, _value);
        return true;
    }

    /**
     * @dev Reset count of tokens approved for given address
     * @param _spender target address
     */
    function unapprove(address _spender)
    { allowances[sha3(msg.sender)][sha3(_spender)] = 0; }
 
    /**
     * @dev Reset count of tokens approved for given ident
     * @param _spender target ident
     */
    function unapprove(bytes32 _spender)
    { allowances[sha3(msg.sender)][_spender] = 0; }
 
    /* Hash driven events */
    event TransferHash(bytes32 indexed _from,  bytes32 indexed _to,      uint256 _value);
    event ApprovalHash(bytes32 indexed _owner, bytes32 indexed _spender, uint256 _value);
}
