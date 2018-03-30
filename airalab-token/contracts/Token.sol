pragma solidity ^0.4.18;

import {Object} from 'airalab-common/contracts/Object.sol';
import './ERC20.sol';

/**
 * @title Token contract represents any asset in digital economy.
 */
contract Token is Object, ERC20 {

    /**
     * @dev Short description of token.
     */
    string public name;

    /**
     * @dev Token acronym (3-4 chars).
     */
    string public symbol;

    /**
     * @dev Fixed point position
     */
    uint8 public decimals;

    /* Token approvement system */
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;

    /**
     * @dev Token constructor
     */
    function Token(
        string _name,
        string _symbol,
        uint8 _decimals,
        uint256 _count
    ) public {
        name        = _name;
        symbol      = _symbol;
        decimals    = _decimals;
        totalSupply = _count;
        balances[msg.sender] = _count;
    }

    /**
     * @dev Get balance of plain address
     * @param _owner is a target address
     * @return amount of tokens on balance
     */
    function balanceOf(address _owner) public view returns (uint256)
    { return balances[_owner]; }

    /**
     * @dev Take allowed tokens
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(address _owner, address _spender) public view returns (uint256)
    { return allowances[_owner][_spender]; }

    /**
     * @dev Transfer self tokens to given address
     * @param _to destination address
     * @param _value amount of token values to send
     * @notice `_value` tokens will be sended to `_to`
     * @return `true` when transfer done
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        if (balances[msg.sender] >= _value) {
            balances[msg.sender] -= _value;
            balances[_to]        += _value;
            emit Transfer(msg.sender, _to, _value);
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
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        uint256 avail = allowances[_from][msg.sender]
                      > balances[_from] ? balances[_from]
                                        : allowances[_from][msg.sender];
        if (avail >= _value) {
            allowances[_from][msg.sender] -= _value;
            balances[_from] -= _value;
            balances[_to]   += _value;
            emit Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    /**
     * @dev Give to target address ability for self token manipulation without sending
     * @param _spender target address (future requester)
     * @param _value amount of token values for approving
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowances[msg.sender][_spender] += _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Reset count of tokens approved for given address
     * @param _spender target address (future requester)
     */
    function unapprove(address _spender) public
    { allowances[msg.sender][_spender] = 0; }
}
