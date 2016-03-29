/*
 * Contract for object that have an owner
 */
contract Owned {
    /* Contract owner address */
    address public owner;

    /* Store owner on creation */
    function Owned() { owner = msg.sender; }

    /* Owner check modifier */
    modifier onlyOwner { if (msg.sender == owner) _ }
}

/*
 * Contract for objects that can be morder
 */
contract Mortal is Owned {
    /* Only owner can kill me */
    function kill() onlyOwner {
        suicide(owner);
    }
}

