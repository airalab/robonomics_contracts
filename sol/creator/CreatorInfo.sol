pragma solidity ^0.4.2;
library CreatorInfo {
    /**
     * @dev Get version of created contract
     */
    function version() constant returns (string);
    /**
     * @dev Get ABI of created contract
     */
    function abi() constant returns (string);
}
