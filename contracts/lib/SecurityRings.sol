pragma solidity ^0.4.2;
/**
 * @dev Simple security rings implementation.
 * The security ring is a method to authorize action by multiple way
 * authorization nodes. Like multisig the security ring accept authorization
 * by a lot of addresses for the action before do it. Abstract is seems like
 * a action should broke a some count of rings that interrupt of this movement,
 * the possible brokable place of ring is a gate, the gates presended as auth 
 * nodes (any Ethereum account or contract). The node can authorize action, in 
 * this case we say that ring is broken. One ring can contain multiple gates,
 * only one open gate is needed for broke the ring.
 */
library SecurityRings {
    struct Data {
        // Authorization node array (1st dim is rings, 2nd dim is gates)
        address[][] auth;
        // Action authorization flags
        mapping(address => bool)[] authorized;
        // Authorization node idents
        mapping(address => bytes32) identOf;
    }

    /**
     * @dev Action authorization check
     * @param _data Storage pointer
     * @param _index Authorization item index
     * @return Authorization status: true - when done
     */
    function isAuthorized(Data storage _data, uint _index) constant returns (bool) {
        var authorized = _data.authorized[_index]; 
        for (uint ring = 0; ring < _data.auth.length; ++ring) {
            bool brokeRing = false;

            for (uint gate = 0; gate < _data.auth[ring].length; ++gate) {
                if (authorized[_data.auth[ring][gate]])
                    brokeRing = true;
            }

            if (!brokeRing) return false;
        }
        return true;
    }

    /**
     * @dev Authorization node info
     * @param _data Storage pointer
     * @param _ring Ring index
     * @param _gate Gate index
     * @return (Auth node address, Auth node ident (user identificator))
     */
    function authAt(Data storage _data, uint _ring, uint _gate)
            constant returns(address, bytes32) {
        var auth = _data.auth[_ring][_gate];
        return (auth, _data.identOf[auth]);
    }

    /**
     * @dev Append new alternative gate into given ring
     * @param _data Storage pointer
     * @param _ring Ring index
     * @param _auth Auth node address
     * @param _ident Auth node ident (user identificator)
     */
    function addGate(Data storage _data, uint _ring, address _auth, bytes32 _ident) {
        _data.auth[_ring].push(_auth);
        _data.identOf[_auth] = _ident;
    }

    /**
     * @dev Append new ring with one default gate
     * @param _data Storage pointer
     * @param _auth Default auth node address
     * @param _ident Default auth node ident (user identificator)
     */
    function addRing(Data storage _data, address _auth, bytes32 _ident)
    { addGate(_data, _data.auth.length++, _auth, _ident); }

    /**
     * @dev Create new action instance
     * @return Action index
     */
    function newAction(Data storage _data) returns (uint)
    { return _data.authorized.length++; }
}
