pragma solidity ^0.4.18;
import 'common/Owned.sol';

contract Streaming is Owned {
    event Stream(bytes32 indexed ident, bool indexed alive);

    bytes32 public streamIdent;
    bool    public streamAlive;

    /**
     * @dev Start streaming
     * @param _ident is a 256 bit identifier of stream (maybe SHA256)
     */
    function streamStart(bytes32 _ident) public {
        require (!streamAlive);

        Stream(_ident, true);
        streamIdent = _ident;
        streamAlive = true;
    }

    /**
     * @dev Terminate streaming
     */
    function streamEnd() public {
        Stream(streamIdent, false);
        streamAlive = false;
    }
}
