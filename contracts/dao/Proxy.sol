pragma solidity ^0.4.18;

import 'common/Object.sol';
import 'lib/SecurityRings.sol';

contract Proxy is Object {
    SecurityRings.Data rings;
    using SecurityRings for SecurityRings.Data;

    /**
     * @dev Authorization node info
     * @param _ring Ring index
     * @param _gate Gate index
     * @return (Auth node address, Auth node ident (user identificator))
     */
    function authAt(uint _ring, uint _gate) public view returns (address, bytes32)
    { return rings.authAt(_ring, _gate); }

    /**
     * @dev Get user identificator for sender node
     */
    function getIdent() public view returns (bytes32)
    { return rings.identOf[msg.sender]; }

    /**
     * @dev Return true when ready to run
     */
    function isAuthorized(uint _index) public view returns (bool)
    { return rings.isAuthorized(_index); }

    /**
     * @dev Initial setup for a new ring
     * @param _gates List of auth node addresses
     * @param _idents List of user identifiers
     */
    function initRing(address[] _gates, bytes32[] _idents) public onlyOwner {
        var ring = rings.auth.length;
        rings.addRing(_gates[0], _idents[0]);
        for (uint i = 1; i < _gates.length; ++i)
            rings.addGate(ring, _gates[i], _idents[i]);
    }

    /**
     * @dev Proxy constructor
     * @param _auth Default auth node
     * @param _ident Default user identifier
     * @param _safe Ring0 safety address
     */
    function Proxy(address _auth, bytes32 _ident, address _safe) public {
        rings.addRing(_auth, _ident);
        rings.addGate(0, _safe, bytes32("safe"));
    }

    struct Call {
        address target;
        uint    value;
        bytes   transaction;
        uint    execBlock;
    }
    Call[] queue;

    /**
     * @dev Get call info by index
     * @param _index Action call index
     */
    function callAt(uint _index) public view returns (address, uint, bytes, uint) {
        var c = queue[_index];
        return (c.target, c.value, c.transaction, c.execBlock);
    }

    /**
     * @dev Get call queue length
     */
    function queueLen() public view returns (uint)
    { return queue.length; }

    /**
     * @dev Transaction request
     * @param _target Transaction destination
     * @param _value Transaction value in wei
     * @param _transaction Transaction data
     */
    function request(address _target, uint _value, bytes _transaction) public {
        var rid = rings.newAction();
        rings.authorized[rid][msg.sender] = true;
        queue.push(Call(_target, _value, _transaction, 0));
        CallRequest(rid);
    }

    /**
     * @dev Call request log
     * @param index Position in call queue
     */
    event CallRequest(uint indexed index);

    /**
     * @dev Authorization of transaction
     * @param _index Call in queue position
     */
    function authorize(uint _index) public {
        require(_index < rings.authorized.length);

        rings.authorized[_index][msg.sender] = true;
        CallAuthorized(_index, msg.sender);
    }

    /**
     * @dev Authorized call event
     * @param index Position in call queue
     * @param node Authorization node
     */
    event CallAuthorized(uint indexed index, address indexed node);

    /**
     * @dev Run action when authorized
     * @param _index Call in queue position
     * @notice This can take a lot of gas
     */
    function run(uint _index) public {
        require(rings.isAuthorized(_index) && queue[_index].execBlock == 0);

        // Store exec block
        queue[_index].execBlock = block.number;

        // Run transaction
        var c = queue[_index];
        require(c.target.call.value(c.value)(c.transaction));
        CallExecuted(_index, block.number);
    }

    /**
     * @dev Executed call event
     * @param index Position in call queue
     * @param block_number Number of call execution block
     */
    event CallExecuted(uint indexed index, uint indexed block_number);

    /**
     * @dev Payable fallback method
     */
    function() public payable
    { PaymentReceived(msg.sender, msg.value); }

    /**
     * @dev Incoming payment event
     * @param from Payment sender
     * @param value Amount of received wei
     */
    event PaymentReceived(address indexed from, uint indexed value);
}
