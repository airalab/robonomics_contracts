pragma solidity ^0.4.2;
import 'common/Owned.sol';

contract Streaming is Owned {
    event Stream(bytes32 indexed ident, bool indexed alive);

    bytes32 public streamIdent;
    bool    public streamAlive;

    /**
     * @dev Start streaming
     * @param _ident is a 256 bit identifier of stream (maybe SHA256)
     */
    function streamStart(bytes32 _ident) {
        if (streamAlive) throw;

        Stream(_ident, true);
        streamIdent = _ident;
        streamAlive = true;
    }

    /**
     * @dev Terminate streaming
     */
    function streamEnd() {
        Stream(streamIdent, false);
        streamAlive = false;
    }
}
