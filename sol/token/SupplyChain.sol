pragma solidity ^0.4.2;
import 'common/Mortal.sol';

/**
 * @title Supply graph item 
 * @dev Supply graph consist of set of items connected by `parent`
 * pointers, usually end user works with leafs because it's a
 * history graph and in this case child pointers skipped.
 */
contract SupplyChain is Mortal {
    struct Transaction {
        uint    stamp;
        string  comment;
    }
    Transaction[] txs;

    /**
     * @dev Take transaction by index
     * @param _index is an index of transaction
     * @return transaction time stamp and comment
     * @notice zero stamp is end of list signal
     */
    function txAt(uint _index) constant returns (uint, string)
    { return (txs[_index].stamp, txs[_index].comment); }

    /**
     * @dev Push transaction to the end of list
     * @param _comment is a string comment of transaction
     * @return true
     */
    function txPush(string _comment) onlyOwner returns (bool) {
        txs.push(Transaction(now, _comment));
        return true;
    }

    SupplyChain[] public parent; 
    uint          public value;

    /**
     * @dev Create supply chain for given parents and value
     */
    function SupplyChain(address[] _parent, uint _value) {
        for (uint i = 0; i < _parent.length; ++i)
            parent.push(SupplyChain(_parent[i]));
        value = _value;
    }
}
