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
        var observers = _observers[_event];
        for (uint i = 0; i < observers.length; ++i)
            if (!observers[i].eventHandle(_event, _data)) throw;
        return true;
    }

    /**
     * @dev Append observer
     * @param _event Event type
     * @param _observer Observer address
     */
    function addObserver(uint _event, Observer _observer) internal
    { _observers[_event].push(_observer); }

    /**
     * @dev Delete observer
     * @param _event Event type
     * @param _observer Observer address
     */
    function delObserver(uint _event, Observer _observer) internal {
        var observers = _observers[_event];
        for (uint i = 0; i < observers.length; ++i)
            if (observers[i] == _observer) {
                if (observers.length > 1)
                    observers[i] = observers[observers.length - 1];
                --observers.length;
                break;
            }
    }
}
