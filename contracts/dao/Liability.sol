pragma solidity ^0.4.4;

import 'common/Object.sol';
import 'token/ERC20.sol';

/**
 * @title Core liability contract
 */
contract Liability is Object {
    /**
     * Params
     */
    address public promisor;
    address public promisee;

    ERC20   public token;
    uint256 public cost;
    
    uint public constant gasbase = 500000;
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
                       address _token,
                       uint256 _cost) {
        promisor = _promisor;
        promisee = _promisee;
        token = ERC20(_token);
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
     * @dev Result handler
     * @param _resultHash 256bit hash of result
     * @return `true` if is ok
     */
    function resultHash(bytes32 _resultHash) internal returns (bool) {
        // Result notification
        resultHash = _resultHash;
        Result(_resultHash);

        // Transfer beneficiar reward
        if (!token.transfer(owner, token.balanceOf(this))) throw;
        return true;
    }

    /**
     * @dev Publish liability result hash
     * @notice Only promisee can call it
     * @param _resultHash 256bit hash of result
     * @return `true` if is ok
     */
    function publishHash(bytes32 _resultHash) returns (bool) {
        // Only promisee can publish the results
        if (msg.sender != promisee) throw;
        return resultHash(_resultHash);
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

        // Send promisee gas expenses
        if (!promisee.send(msg.value)) throw;
        
        return true;
    }
    
    /**
     * @dev External owned account oriented payment
     * @notice Tokens should be transfered before send ethers
     */
    function () payable
    { if (!payment(tx.gasprice)) throw; }
}
