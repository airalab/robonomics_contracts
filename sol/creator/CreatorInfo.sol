library CreatorInfo {
    /**
     * @dev Get version of created contract
     */
    function version() constant returns (string);
    /**
     * @dev Get ABI of created contract
     */
    function interface() constant returns (string);
}
