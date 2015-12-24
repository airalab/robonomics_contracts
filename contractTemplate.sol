contract contractTemplate {
	address promisor;
	address promisee;
	address beneficiary;

	bool promisorAgree;
	bool promiseeAgree;

	function contractTemplate(address _promisee, address _beneficiary) {
		promisor = msg.sender;
		promisee = _promisee;
		beneficiary = _beneficiary;
	}

	function signContract() returns(bool result) {
		if(msg.sender == promisor) {promisorAgree = true; return true;}
		else (msg.sender == promisee) {promiseeAgree = true; return true;}
		return false;
	}
}