import 'common/Mortal.sol';

contract ContractTemplate is Mortal {
    address promisor;
    address promisee;
    address beneficiary;

    bool promisorAgree;
    bool promiseeAgree;

    struct Transfer {
        address token;
        string tokenItemscope;
        uint amount;
        bool transferSend;
        bool transferReceive;
    }

    Transfer promisorTransfer;
    Transfer promiseeTransfer;

    function ContractTemplate(address _promisee, address _beneficiary) {
        promisor = msg.sender;
        promisee = _promisee;
        beneficiary = _beneficiary;
    }

    function signContract() returns(bool result) {
        if (msg.sender == promisor) {
            promisorAgree = true;
            return true;
        } else if (msg.sender == promisee) {
            promiseeAgree = true;
            return true;
        }
        return false;
    }

    function makeContract() returns (address);
}
