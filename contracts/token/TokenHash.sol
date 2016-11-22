pragma solidity ^0.4.4;
import 'common/Mortal.sol';
import './ERC20.sol';

/**
 * @title Token compatible contract represents any asset in digital economy
 * @dev Accounting based on sha3 hashed identifiers
 */
contract TokenHash is Mortal, ERC20 {
    event TransferHash(bytes32 indexed _from,  bytes32 indexed _to,      uint256 _value);
    event ApprovalHash(bytes32 indexed _owner, bytes32 indexed _spender, uint256 _value);

    /* Short description of token */
    string public name;
    string public symbol;

    /* Total count of tokens exist */
    uint public totalSupply;

    /* Fixed point position */
    uint8 public decimals;
    
    /* Token approvement system */
    mapping(bytes32 => uint) public balanceOf;
    mapping(bytes32 => mapping(bytes32 => uint)) public allowance;
 
    /* Token constructor */
    function TokenHash(string _name, string _symbol, uint8 _decimals, uint _count) {
        name        = _name;
        symbol      = _symbol;
        decimals    = _decimals;
        totalSupply = _count;
        balanceOf[sha3(msg.sender)] = _count;
    }
 
    /**
     * @dev Transfer self tokens to given address
     * @param _to destination address
     * @param _value amount of token values to send
     * @notice `_value` tokens will be sended to `_to`
     * @return `true` when transfer done
     */
    function transfer(address _to, uint _value) returns (bool) {
        var sender = sha3(msg.sender);

        if (balanceOf[sender] >= _value) {
            balanceOf[sender]    -= _value;
            balanceOf[sha3(_to)] += _value;
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
    function transfer(bytes32 _to, uint _value) returns (bool) {
        var sender = sha3(msg.sender);

        if (balanceOf[sender] >= _value) {
            balanceOf[sender] -= _value;
            balanceOf[_to]    += _value;
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
    function transferFrom(address _from, address _to, uint _value) returns (bool) {
        var to    = sha3(_to);
        var from  = sha3(_from);
        var sender= sha3(msg.sender);
        var avail = allowance[from][sender]
                  > balanceOf[from] ? balanceOf[from]
                                    : allowance[from][sender];
        if (avail >= _value) {
            allowance[from][sender] -= _value;
            balanceOf[from] -= _value;
            balanceOf[to]   += _value;
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
    function transferFrom(bytes32 _from, bytes32 _to, uint _value) returns (bool) {
        var sender= sha3(msg.sender);
        var avail = allowance[_from][sender]
                  > balanceOf[_from] ? balanceOf[_from]
                                     : allowance[_from][sender];
        if (avail >= _value) {
            allowance[_from][sender] -= _value;
            balanceOf[_from] -= _value;
            balanceOf[_to]   += _value;
            TransferHash(_from, _to, _value);
            return true;
        }
        return false;
    }

    /**
     * @dev Give to target address ability for self token manipulation without sending
     * @param _sender target address (future requester)
     * @param _value amount of token values for approving
     */
    function approve(address _sender, uint _value) returns (bool) {
        allowance[sha3(msg.sender)][sha3(_sender)] += _value;
        Approval(msg.sender, _sender, _value);
        return true;
    }
 
    /**
     * @dev Give to target ident ability for self token manipulation without sending
     * @param _sender target ident (future requester)
     * @param _value amount of token values for approving
     */
    function approve(bytes32 _sender, uint _value) returns (bool) {
        allowance[sha3(msg.sender)][_sender] += _value;
        ApprovalHash(sha3(msg.sender), _sender, _value);
        return true;
    }

    /**
     * @dev Reset count of tokens approved for given address
     * @param _sender target address
     */
    function unapprove(address _sender)
    { allowance[sha3(msg.sender)][sha3(_sender)] = 0; }
 
    /**
     * @dev Reset count of tokens approved for given ident
     * @param _sender target ident
     */
    function unapprove(bytes32 _sender)
    { allowance[sha3(msg.sender)][_sender] = 0; }
}
