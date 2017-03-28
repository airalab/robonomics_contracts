pragma solidity ^0.4.4;

import 'common/Object.sol';
import 'token/ERC20.sol';

/**
 * @title Liability contract
 */
contract Liability is Object {
    /**
     * Params
     */
    address public promisor;
    address public promisee;

    ERC20   public token;
    uint256 public cost;
    
    uint public constant gasbase = 100000;
    uint public gasprice;

    /**
     * @dev Create liability contract
     * @param _promisor Promisor account
     * @param _promisee Promisee account
     * @param _token Payment token contract
     * @param _cost Liability cost
     */
    function Liability(address _promisor,
                       address _promisee,
                       ERC20 _token,
                       uint256 _cost) {
        promisor = _promisor;
        promisee = _promisee;
        token = _token;
        cost = _cost;
    }

    /**
     * @dev Emitted for every received result hash
     */
    event Result(bytes32 indexed hash);

    /**
     * @dev Current result hash
     */
    bytes32 public resultHash;

    /**
     * @dev Publish liability result
     * @notice Only promisor can call it
     * @param _resultHash 256bit hash of result
     * @return `true` if is ok
     */
    function publish(bytes32 _resultHash) returns (bool) {
        // Only promisor can publish the results
        if (msg.sender != promisor) throw;

        // Result notification
        resultHash = _resultHash;
        Result(_resultHash);

        // Transfer beneficiar reward
        if (!token.transfer(owner, token.balanceOf(this))) throw;
        return true;
    }
    
    /**
     * @dev Process liability payment
     * @notice Tokens should be transfered before call it
     */
    function payment(uint _gasprice) payable returns (bool) {
        // Store gas price
        gasprice = _gasprice;

        // Check payment
        if (token.balanceOf(this) < cost
          || msg.value < gasprice * gasbase) throw;

        // Send promisor gas expenses
        if (!promisor.send(msg.value)) throw;
        
        return true;
    }
    
    /**
     * @dev External owned account oriented payment
     * @notice Tokens should be transfered before send ethers
     */
    function () payable
    { if (!payment(tx.gasprice)) throw; }
}
