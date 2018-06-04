pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/ECRecovery.sol';
import './RobotLiability.sol';
import './Lighthouse.sol';
import './XRT.sol';

import 'ens/contracts/ENS.sol';
import 'ens/contracts/ENSRegistry.sol';
import 'ens/contracts/PublicResolver.sol';

contract LiabilityFactory {
    using ECRecovery for bytes32;

    constructor(
        address _robotLiabilityLib,
        address _lighthouseLib,
        XRT _xrt
    ) public {
        robotLiabilityLib = _robotLiabilityLib;
        lighthouseLib = _lighthouseLib;
        xrt = _xrt;
    }

    /**
     * @dev Robonomics network protocol token
     */
    XRT public xrt;

    /**
     * @dev Ethereum name system
     */
    ENS public ens;

    /**
     * @dev Robonomics ENS resolver
     */
    PublicResolver public resolver;

    bytes32 constant lighthouseNode
        // lighthouse.0.robonomics.eth
        = 0x1e42a8e8e1e8cf36e83d096dcc74af801d0a194a14b897f9c8dfd403b4eebeda;

    function setENS(ENS _ens) public {
      require(address(ens) == 0);
      ens = _ens;
      resolver = PublicResolver(ens.resolver(lighthouseNode));
    }

    /**
     * @dev Total GAS utilized by Robonomics network
     */
    uint256 public totalGasUtilizing = 0;

    /**
     * @dev Used market orders accounting
     */
    mapping(bytes32 => bool) public usedHash;

    /**
     * @dev Lighthouse accounting
     */
    mapping(address => bool) public isLighthouse;

     /* Events */
    event NewLiability(address indexed liability);
    event NewLighthouse(address indexed lighthouse);

    /**
     * @dev Last created liability smart contract
     */
    RobotLiability public lastLiability;

    /**
     * @dev Robot liability shared code smart contract
     */
    address public robotLiabilityLib;

    /**
     * @dev Lightouse shared code smart contract
     */
    address public lighthouseLib;

    /**
     * @dev Gas based XRT minting
     */
    modifier gasBasedMint {
        uint256 gasinit = gasleft();
        require(gasinit >= 800000);
        
        _;

        // Gas used = limit - left + uncounted expenses: emission, transfer, finalization
        uint256 gas = gasinit - gasleft();
        totalGasUtilizing += gas;
        require(xrt.mint(lastLiability, winnerFromGas(gas)));
    }

    /**
     * @dev XRT emission value for utilized gas
     */
    function winnerFromGas(uint256 gas) public view returns (uint256) {
        // Basic equal formula
        uint256 wn = gas;

        /* Additional emission table */
        if (totalGasUtilizing < 856368000) {
            wn *= 37;
        } else if (totalGasUtilizing < 856368000 * 2) {
            wn *= 25;
        } else if (totalGasUtilizing < 856368000 * 3) {
            wn *= 17;
        } else if (totalGasUtilizing < 856368000 * 4) {
            wn *= 11;
        } else if (totalGasUtilizing < 856368000 * 5) {
            wn *= 7;
        } else if (totalGasUtilizing < 856368000 * 6) {
            wn *= 5;
        } else if (totalGasUtilizing < 856368000 * 7) {
            wn *= 3;
        } else if (totalGasUtilizing < 856368000 * 8) {
            wn *= 2;
        }

        return wn ;
    }

    /**
     * @dev Only lighthouse guard
     */
    modifier onlyLighthouses {
        require(isLighthouse[msg.sender]);
        _;
    }

    /**
     * @dev Create robot liability contract
     * @param _model CPS behaviour model (structure of the system) 
     * @param _objective CPS behaviour params (dynamic params of the system)
     * @param _askSignature Ask signature
     * @param _bidSignature Ask signature
     * @param _params List of order params 
     *
     * '_params' is a list of:
     * - liability cost
     * - lighthouse fee (only for promisor)
     * - validator fee (only for promisee, optional)
     * - ask deadline block number
     * - bid deadline block number
     * - ask nonce number
     * - bid nonce number
     * - processing token address
     * - liability validator address (optional)
     */
    function createLiability(
        bytes      _model,
        bytes      _objective,
        bytes      _askSignature,
        bytes      _bidSignature,
        uint256[9] _params
    )
        external
        gasBasedMint 
        onlyLighthouses
    {
        require(block.number < _params[3]);
        require(block.number < _params[4]);

        bytes32 askHash = keccak256(
            _model,
            _objective,
            _params[7],
            _params[8],
            _params[0],
            _params[2],
            _params[5],
            _params[3]
        );

        bytes32 bidHash = keccak256(
            _model,
            _objective,
            _params[7],
            _params[0],
            _params[1],
            _params[6],
            _params[4]
        );

        require(!usedHash[askHash] && !usedHash[bidHash]);
        usedHash[askHash] = true;
        usedHash[bidHash] = true;

        address promisee = askHash
            .toEthSignedMessageHash()
            .recover(_askSignature); 

        address promisor = bidHash
            .toEthSignedMessageHash()
            .recover(_bidSignature); 

        lastLiability = new RobotLiability(
            robotLiabilityLib,
            _model,
            _objective,
            ERC20(_params[7]),
            [_params[0], _params[1], _params[2]],
            [promisee, promisor, address(_params[8])]
        );

        emit NewLiability(lastLiability);

        // Tnasfer fee for lighthouse
        require(xrt.transferFrom(promisor, msg.sender, _params[1]));

        // Transfer token security
        require(ERC20(_params[7]).transferFrom(promisee, lastLiability, _params[0]));

        // Transfer fee for validator
        if (_params[8] != 0 && _params[2] > 0)
            require(xrt.transferFrom(promisee, lastLiability, _params[2]));
    }

    /**
     * @dev Create lighthouse
     * @param _minimalFreeze Minimal freeze value of XRT token
     */
    function createLighthouse(
        uint256 _minimalFreeze
      , uint256 _timeoutBlocks
      , string  _name
    ) external returns (Lighthouse lighthouse) {
        lighthouse = new Lighthouse(lighthouseLib, _minimalFreeze, _timeoutBlocks);

        ens.setSubnodeOwner(lighthouseNode, keccak256(_name), this);
        ens.setResolver(keccak256(lighthouseNode, keccak256(_name)), resolver);
        resolver.setAddr(keccak256(lighthouseNode, keccak256(_name)), lighthouse);

        isLighthouse[lighthouse] = true;
        emit NewLighthouse(lighthouse);
    }
}
