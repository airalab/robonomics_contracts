pragma solidity ^0.4.4;

contract Observer {
    /**
     * @dev Handle observable contract event
     * @param _event Event type
     * @param _data Event data
     * @return `true` if success done
     */
    function eventHandle(uint _event, bytes32[] _data) returns (bool)
    { return true; }
}

contract Observable {
    mapping(uint => Observer[]) private _observers;

    /**
     * @dev Notify observers 
     * @param _event Event type
     * @notice Potentialy DoS vulnerable by observer contract, be carefull
     */
    function notify(uint _event, bytes32[] _data) internal returns (bool) {
        for (uint i = 0; i < _observers[_event].length; ++i)
            if (!_observers[_event][i].eventHandle(_event, _data)) throw;
        return true;
    }

    /**
     * @dev Append new observer
     * @param _event Event type
     * @param _observer Target address
     */
    function addObserver(uint _event, Observer _observer) internal
    { _observers[_event].push(_observer); }
}
