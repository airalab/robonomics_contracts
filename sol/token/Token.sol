import 'common/Owned.sol';

/**
 * @title Token contract represents any asset in digital economy
 */
contract Token is Owned {
    event Transfer(address indexed _from,  address indexed _to,      uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /* Short description of token */
    string public name;
    string public symbol;

    /* Total count of tokens exist */
    uint public totalSupply;

    /* Fixed point position */
    uint8 public decimals;
    
    /* Token approvement system */
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;
 
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
        return allowance[_address][msg.sender]
             > balanceOf[_address] ? balanceOf[_address]
                                   : allowance[_address][msg.sender];
    }
 
    /* Token constructor */
    function Token(string _name, string _symbol, uint8 _decimals, uint _count) {
        name     = _name;
        symbol   = _symbol;
        decimals = _decimals;
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
            Transfer(msg.sender, _to, _value);
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
        var avail = allowance[_from][msg.sender]
                  > balanceOf[_from] ? balanceOf[_from]
                                     : allowance[_from][msg.sender];
        if (avail >= _value) {
            allowance[_from][msg.sender] -= _value;
            balanceOf[_from] -= _value;
            balanceOf[_to]   += _value;
            Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    /**
     * @dev Give to target address ability for self token manipulation without sending
     * @param _address target address
     * @param _value amount of token values for approving
     */
    function approve(address _address, uint _value) {
        allowance[msg.sender][_address] += _value;
        Approval(msg.sender, _address, _value);
    }

    /**
     * @dev Reset count of tokens approved for given address
     * @param _address target address
     */
    function unapprove(address _address)
    { allowance[msg.sender][_address] = 0; }
}
