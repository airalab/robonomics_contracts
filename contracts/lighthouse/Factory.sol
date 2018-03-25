pragma solidity ^0.4.18;

import 'token/TokenEmission.sol';
import './RobotLiability.sol';
import './Lighthouse.sol';

contract Factory {
    function Factory(TokenEmission _xrt) public {
        xrt = _xrt;
    }

    /* Constants */
    bytes constant MSGPREFIX = "\x19Ethereum Signed Message:\n32";

    /**
     * @dev Robonomics network utility token
     */
    TokenEmission public xrt;

    /**
     * @dev Total GAS utilized by Robonomics network
     */
    uint256 public totalGasUtilizing = 0;

    /**
     * @dev Used market order hashes tracking.
     */
    mapping(bytes32 => bool) public usedHash;

    RobotLiability[] public buildedLiability;
    Lighthouse[]     public buildedLighthouse;

    mapping(address => bool) public isBuiled;

    /* Events */
    event BuildedLiability(address indexed robotLiability);
    event BuildedLighthouse(address indexed lighthouse);

    /**
     * @dev Create robot liability contract
     * @param _model Robot behaviour model
     * @param _objective Task for the robot
     * @param _token Operational token
     * @param _expenses Liability creation expenses
     * @param _sign Liability cyptographic params
     * @param _deadline Messages deadline params
     *
     * '_sign' is a list of:
     * - [0]   => promisee nonce
     * - [1-3] => promisee EC signature (v, r, s)
     * - [4]   => promisor nonce
     * - [5-7] => promisor EC signature (v, r, s)
     *
     * '_expenses' is a list of:
     * - execution cost (cost * count)
     * - lighthouse fee (only for promisor)
     * - validator fee (only for promisee)
     *
     * '_deadline' is a list of:
     * - ASK deadline block number
     * - BID deadline block number
     *
     */
    function createLiability(
        bytes32 _model,
        bytes32 _objective,
        ERC20   _token,
        address _validator,
        uint256[3] _expenses,
        bytes32[8] _sign,
        uint256[2] _deadline
    ) public returns (RobotLiability liability) {
        uint256 gasinit = gasleft();
        require(gasinit >= 700000);

        require(isBuiled[msg.sender]);

        require(block.number < _deadline[0]);
        require(block.number < _deadline[1]);

        bytes32 askHash = keccak256(_model,
                                    _objective,
                                    _token,
                                    _validator,
                                    _expenses[0],
                                    _expenses[2],
                                    _sign[0],
                                    _deadline[0]);
        bytes32 bidHash = keccak256(_model,
                                    _token,
                                    _expenses[0],
                                    _expenses[1],
                                    _sign[4],
                                    _deadline[1]);

        require(!usedHash[askHash] && !usedHash[bidHash]);
        usedHash[askHash] = true;
        usedHash[bidHash] = true;

        address promisee = ecrecover(keccak256(MSGPREFIX, askHash), uint8(_sign[1]), _sign[2], _sign[3]);
        address promisor = ecrecover(keccak256(MSGPREFIX, bidHash), uint8(_sign[5]), _sign[6], _sign[7]);

        // Instantiate liability contract
        liability = new RobotLiability(_model,
                                       _objective,
                                       _token,
                                       _expenses,
                                       [promisee, promisor, msg.sender, _validator]);
        buildedLiability.push(liability);
        isBuiled[liability] = true;
        emit BuildedLiability(liability);

        // Tnasfer robot fee for lighthouse
        require(xrt.transferFrom(promisor, msg.sender, _expenses[1]));

        // Transfer token security
        require(_token.transferFrom(promisee, liability, _expenses[0]));

        // Transfer promisee fee for validator
        if (_validator != 0 && _expenses[2] > 0)
            require(xrt.transferFrom(promisee, liability, _expenses[2]));

        // Transfer XRT emission for finalization
        require(xrt.transfer(liability, xrt_emission(gasinit - gasleft())));
    }

    function xrt_emission(uint256 gas) internal returns (uint256) {
        // Gas used = limit - left + uncounted expenses: emission, transfer, finalization
        totalGasUtilizing += gas;

        uint256 wnEmission = gas;
        /* Additional emission table */
        if (totalGasUtilizing < 856368000) {
            wnEmission *= 37;
        } else if (totalGasUtilizing < 856368000 * 2) {
            wnEmission *= 25;
        } else if (totalGasUtilizing < 856368000 * 3) {
            wnEmission *= 17;
        } else if (totalGasUtilizing < 856368000 * 4) {
            wnEmission *= 11;
        } else if (totalGasUtilizing < 856368000 * 5) {
            wnEmission *= 7;
        } else if (totalGasUtilizing < 856368000 * 6) {
            wnEmission *= 5;
        } else if (totalGasUtilizing < 856368000 * 7) {
            wnEmission *= 3;
        } else if (totalGasUtilizing < 856368000 * 8) {
            wnEmission *= 2;
        }
        xrt.emission(wnEmission);
        return wnEmission;
    }

    /**
     * @dev Create lighthouse
     * @param _minimalFreeze Minimal freeze value of XRT token
     */
    function createLighthouse(
        uint256 _minimalFreeze
    ) public returns (Lighthouse lighthouse) {
        lighthouse = new Lighthouse(_minimalFreeze);

        buildedLighthouse.push(lighthouse);
        isBuiled[lighthouse] = true;
        emit BuildedLighthouse(lighthouse);
    }
}
