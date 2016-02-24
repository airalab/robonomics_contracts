import "pie";

contract agent {

    address public creator;

    uint public typeAgent;

    function agent() {
		creator = msg.sender;
    }
	
    function getBalance(address _token) returns (uint256 balance) {
        return pie(_token).getBalance(creator);
    }
	
    function transfer(address _asset, address _to, uint256 _value) returns (bool) {
		return false;
    }
}
