pragma solidity ^0.4.4;
import 'common/Owned.sol';
import 'common/Destroyable.sol';

/**
 * @title Generic owned destroyable contract
 */
contract Object is Owned, Destroyable {
    function Object() {
        owner  = msg.sender;
        hammer = msg.sender;
    }
}
