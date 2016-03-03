contract ethertoken is token {
    
    /*Initial */
    function ethertoken() {
        creator = msg.sender;
        symbol = "Wei";
        name = "EthContractWallet";
    }
    
    function loadBalance() {
        balanceOf[msg.sender] += msg.value;
        totalSupply += msg.value;
        
    }
    
    function withdraw(uint256 _value) returns (bool result){
        if (balanceOf[msg.sender] < _value) {return false;}
        msg.sender.send(_value);
        return true;
        
    }    
    
    function () {
        // This function gets executed if a
        // transaction with invalid data is sent to
        // the contract or just ether without data.
        // We revert the send so that no-one
        // accidentally loses money when using the
        // contract.
        throw;
    }
    
}
