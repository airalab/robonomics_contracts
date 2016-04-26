import 'common.sol';

/**
 * @title Token contract represents any asset in digital economy
 */
contract Token is Mortal {
    struct Config {
        /* Short description of token */
        string name;
        string symbol;
        /* Total count of tokens exist */
        uint total;
        /* Token approvement system */
        mapping (address => uint) balanceOf;
        mapping (address => mapping (address => uint)) approveOf;
    }

    Config token;
 
    /* Public token getters */
    function getName() constant returns (string)
    { return token.name; }
 
    function getSymbol() constant returns (string)
    { return token.symbol; }

    /**
     * @return amount of token values are emitted
     */
    function getTotalSupply() constant returns (uint)
    { return token.total; }
 
    /**
     * @return available balance of `sender` account (self balance)
     */
    function getBalance() constant returns (uint)
    { return token.balanceOf[msg.sender]; }
 
    /**
     * @dev This method returns non zero result when sender is approved by
     *      argument address and target address have non zero self balance
     * @param _address target address 
     * @return available for `sender` balance of given address
     */
    function getBalance(address _address) constant returns (uint) {
        return token.approveOf[_address][msg.sender]
             > token.balanceOf[_address] ? token.balanceOf[_address]
                                         : token.approveOf[_address][msg.sender];
    }
 
    /**
     * @return `true` wnen `sender` have non zero available balance for target address 
     * @dev Synonym for getBalance(address _address)
     */
    function isApproved(address _address) constant returns (bool)
    { return getBalance(_address) > 0; }

    /* Token constructor */
    function Token(string _name, string _symbol) {
        token.name   = _name;
        token.symbol = _symbol;
    }
    
    /*
     * Token manipulation methods only for owner
     */
    
    /**
     * @dev Token emission
     * @param _value amount of token values to emit
     * @notice owner balance will be increased by `_value`
     */
    function emission(uint _value) onlyOwner {
        token.total            += _value;
        token.balanceOf[owner] += _value;
    }
 
    /**
     * @dev Burn the token values from owner balance and from total
     * @param _value amount of token values for burn 
     * @notice owner balance will be decreased by `_value`
     */
    function burn(uint _value) onlyOwner {
        if (token.balanceOf[owner] >= _value) {
            token.balanceOf[owner] -= _value;
            token.total            -= _value;
        }
    }

    /*
     * Public token methods for everyone
     */

    /**
     * @dev Transfer self tokens to given address
     * @param _to destination address
     * @param _value amount of token values to send
     * @notice `_value` tokens will be sended to `_to`
     * @return `true` when transfer done
     */
    function transfer(address _to, uint _value) returns (bool) {
        if (token.balanceOf[msg.sender] >= _value) {
            token.balanceOf[msg.sender] -= _value;
            token.balanceOf[_to]        += _value;
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
        if (getBalance(_from) >= _value) {
            token.approveOf[_from][msg.sender] -= _value;
            token.balanceOf[_from] -= _value;
            token.balanceOf[_to]   += _value;
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
    { token.approveOf[msg.sender][_address] += _value; }

    /**
     * @dev Reset count of tokens approved for given address
     * @param _address target address
     */
    function unapprove(address _address)
    { token.approveOf[msg.sender][_address] = 0; }
}
