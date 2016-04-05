import 'common.sol';

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
    { return token.symbol;}
    
    function getTotalSupply() constant returns (uint)
    { return token.total; }
    
    function getBalance() constant returns (uint)
    { return token.balanceOf[msg.sender]; }
    
    function getBalance(address _address) constant returns (uint) {
        return token.approveOf[_address][msg.sender]
             > token.balanceOf[_address] ? token.balanceOf[_address]
                                         : token.approveOf[_address][msg.sender];
    }
    
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
    
    /* Token emission */
    function emission(uint _value) onlyOwner {
        token.total            += _value;
        token.balanceOf[owner] += _value;
    }
    
    /* Burn the token values */
    function burn(uint _value) onlyOwner {
        if (token.balanceOf[owner] >= _value) {
            token.balanceOf[owner] -= _value;
            token.total            -= _value;
        }
    }

    /*
     * Public token methods for everyone
     */

    function transfer(address _to, uint _value) returns (bool) {
        if (token.balanceOf[msg.sender] >= _value) {
            token.balanceOf[msg.sender] -= _value;
            token.balanceOf[_to]        += _value;
            return true;
        }
        return false;
    }

    function transferFrom(address _from, address _to, uint _value) returns (bool) {
        if (getBalance(_from) >= _value) {
            token.approveOf[_from][msg.sender] -= _value;
            token.balanceOf[_from] -= _value;
            token.balanceOf[_to]   += _value;
            return true;
        }
        return false;
    }

    function approve(address _address, uint _value)
    { token.approveOf[msg.sender][_address] = _value; }

    function unapprove(address _address)
    { token.approveOf[msg.sender][_address] = 0; }
}
