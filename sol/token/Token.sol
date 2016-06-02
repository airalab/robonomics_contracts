/**
 * @title Token contract represents any asset in digital economy
 */
contract Token {
    /* Short description of token */
    string public name;
    string public symbol;

    /* Total count of tokens exist */
    uint public totalSupply;
    
    /* Token approvement system */
    mapping(address => uint) public balanceOf;
    mapping(address => mapping (address => uint)) public approveOf;
 
    /**
     * @return available balance of `sender` account (self balance)
     */
    function getBalance() constant returns (uint)
    { return balanceOf[msg.sender]; }
 
    /**
     * @dev This method returns non zero result when sender is approved by
     *      argument address and target address have non zero self balance
     * @param _address target address 
     * @return available for `sender` balance of given address
     */
    function getBalance(address _address) constant returns (uint) {
        return approveOf[_address][msg.sender]
             > balanceOf[_address] ? balanceOf[_address]
                                   : approveOf[_address][msg.sender];
    }
 
    /**
     * @return `true` wnen `sender` have non zero available balance for target address 
     * @dev Synonym for getBalance(address _address)
     */
    function isApproved(address _address) constant returns (bool)
    { return approveOf[_address][msg.sender] > 0; }

    /* Token constructor */
    function Token(string _name, string _symbol, uint _count) {
        name   = _name;
        symbol = _symbol;
        totalSupply           = _count;
        balanceOf[msg.sender] = _count;
    }
    
    /**
     * @dev Transfer self tokens to given address
     * @param _to destination address
     * @param _value amount of token values to send
     * @notice `_value` tokens will be sended to `_to`
     * @return `true` when transfer done
     */
    function transfer(address _to, uint _value) returns (bool) {
        if (balanceOf[msg.sender] >= _value) {
            balanceOf[msg.sender] -= _value;
            balanceOf[_to]        += _value;
            return true;
        }
        return false;
    }

    /**
     * @dev Transfer with approvement mechainsm
     * @param _from source address, `_value` tokens shold be approved for `sender`
     * @param _to destination address
     * @param _value amount of token values to send 
     * @notice from `_from` will be sended `_value` tokens to `_to`
     * @return `true` when transfer is done
     */
    function transferFrom(address _from, address _to, uint _value) returns (bool) {
        var avail = approveOf[_from][msg.sender]
                  > balanceOf[_from] ? balanceOf[_from]
                                     : approveOf[_from][msg.sender];
        if (avail >= _value) {
            approveOf[_from][msg.sender] -= _value;
            balanceOf[_from] -= _value;
            balanceOf[_to]   += _value;
            return true;
        }
        return false;
    }

    /**
     * @dev Give to target address ability for self token manipulation without sending
     * @param _address target address
     * @param _value amount of token values for approving
     */
    function approve(address _address, uint _value)
    { approveOf[msg.sender][_address] += _value; }

    /**
     * @dev Reset count of tokens approved for given address
     * @param _address target address
     */
    function unapprove(address _address)
    { approveOf[msg.sender][_address] = 0; }
}
