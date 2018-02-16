pragma solidity ^0.4.18;

import './Owned.sol';
import './Destroyable.sol';

/**
 * @title Generic owned destroyable contract
 */
contract Object is Owned, Destroyable {
    function Object() public {
        owner  = msg.sender;
        hammer = msg.sender;
    }
}
