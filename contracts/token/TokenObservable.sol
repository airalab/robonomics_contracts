pragma solidity ^0.4.4;
import 'common/Observer.sol';
import './ERC20.sol';

contract TokenObservable is ERC20, Observable {
    uint public constant TRANSFER_EVENT = 0x10;
    uint public constant APPROVE_EVENT  = 0x20;

    function transfer(address _to, uint _value) returns (bool) {
        bytes32[] memory data = new bytes32[](3);
        data[0] = bytes32(msg.sender);
        data[1] = bytes32(_to);
        data[2] = bytes32(_value);
        if (!notify(TRANSFER_EVENT, data)) throw;

        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) returns (bool) {
        bytes32[] memory data = new bytes32[](3);
        data[0] = bytes32(_from);
        data[1] = bytes32(_to);
        data[2] = bytes32(_value);
        if (!notify(TRANSFER_EVENT, data)) throw;

        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) returns (bool) {
        bytes32[] memory data = new bytes32[](3);
        data[0] = bytes32(msg.sender);
        data[1] = bytes32(_spender);
        data[2] = bytes32(_value);
        if (!notify(APPROVE_EVENT, data)) throw;

        return super.approve(_spender, _value);
    }
}
