pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol';

import '../ens/AbstractENS.sol';
import '../ens/AbstractResolver.sol';
import '../misc/SingletonHash.sol';
import '../misc/DutchAuction.sol';
import '../misc/SharedCode.sol';

import './interface/IFactory.sol';

import './Lighthouse.sol';
import './Liability.sol';
import './XRT.sol';

contract Factory is IFactory, SingletonHash {
    constructor(
        address _liability,
        address _lighthouse,
        DutchAuction _auction,
        AbstractENS _ens,
        XRT _xrt
    ) public {
        liabilityCode = _liability;
        lighthouseCode = _lighthouse;
        auction = _auction;
        ens = _ens;
        xrt = _xrt;
    }

    address public liabilityCode;
    address public lighthouseCode;

    using SafeERC20 for XRT;
    using SafeERC20 for ERC20;
    using SharedCode for address;

    /**
     * @dev Robonomics dutch auction contract
     */
    DutchAuction public auction;

    /**
     * @dev Ethereum name system
     */
    AbstractENS public ens;

    /**
     * @dev Robonomics network protocol token
     */
    XRT public xrt;

    /**
     * @dev SMMA filter with function: SMMA(i) = (SMMA(i-1)*(n-1) + PRICE(i)) / n
     * @param _prePrice PRICE[n-1]
     * @param _price PRICE[n]
     * @return filtered price
     */
    function smma(uint256 _prePrice, uint256 _price) internal pure returns (uint256) {
        return (_prePrice * (smmaPeriod - 1) + _price) / smmaPeriod;
    }

    /**
     * @dev SMMA filter period
     */
    uint256 private constant smmaPeriod = 1000;

    /**
     * @dev XRT emission value for utilized gas
     */
    function wnFromGas(uint256 _gas) public view returns (uint256) {
        // Just return wn=gas*150 when auction isn't finish
        if (auction.finalPrice() == 0)
            return _gas * 150;

        // Current gas utilization epoch
        uint256 epoch = totalGasConsumed / gasEpoch;

        // XRT emission with addition coefficient by gas utilzation epoch
        uint256 wn = _gas * 10**9 * gasPrice * 2**epoch / 3**epoch / auction.finalPrice();

        // Check to not permit emission decrease below wn=gas
        return wn < _gas ? _gas : wn;
    }

    modifier onlyLighthouse {
        require(isLighthouse[msg.sender]);

        _;
    }

    modifier gasPriceEstimate {
        gasPrice = smma(gasPrice, tx.gasprice);

        _;
    }

    function createLighthouse(
        uint256 _minimalStake,
        uint256 _timeoutInBlocks,
        string  calldata _name
    )
        external
        returns (ILighthouse lighthouse)
    {
        bytes32 LIGHTHOUSE_NODE
            // lighthouse.5.robonomics.eth
            = 0x8d6c004b56cbe83bbfd9dcbd8f45d1f76398267bbb130a4629d822abc1994b96;
        bytes32 hname = keccak256(bytes(_name));

        // Name reservation check
        bytes32 subnode = keccak256(abi.encodePacked(LIGHTHOUSE_NODE, hname));
        require(ens.resolver(subnode) == address(0));

        // Create lighthouse
        lighthouse = ILighthouse(lighthouseCode.proxy());
        require(Lighthouse(address(lighthouse)).setup(xrt, _minimalStake, _timeoutInBlocks));

        emit NewLighthouse(address(lighthouse), _name);
        isLighthouse[address(lighthouse)] = true;

        // Register subnode
        ens.setSubnodeOwner(LIGHTHOUSE_NODE, hname, address(this));

        // Register lighthouse address
        AbstractResolver resolver = AbstractResolver(ens.resolver(LIGHTHOUSE_NODE));
        ens.setResolver(subnode, address(resolver));
        resolver.setAddr(subnode, address(lighthouse));
    }

    function createLiability(
        bytes calldata _demand,
        bytes calldata _offer
    )
        external
        onlyLighthouse
        returns (ILiability liability)
    {
        // Create liability
        liability = ILiability(liabilityCode.proxy());
        require(Liability(address(liability)).setup(xrt));

        emit NewLiability(address(liability));

        // Parse messages
        (bool success, bytes memory returnData)
            = address(liability).call(abi.encodePacked(bytes4(0x48a984e4), _demand)); // liability.demand(...)
        require(success);
        singletonHash(liability.demandHash());
        nonceOf[liability.promisee()] += 1;

        (success, returnData)
            = address(liability).call(abi.encodePacked(bytes4(0x413781d2), _offer)); // liability.offer(...)
        require(success);
        singletonHash(liability.offerHash());
        nonceOf[liability.promisor()] += 1;

        // Check lighthouse
        require(isLighthouse[liability.lighthouse()]);

        // Transfer lighthouse fee to lighthouse worker directly
        if (liability.lighthouseFee() > 0)
            xrt.safeTransferFrom(liability.promisor(),
                                 tx.origin,
                                 liability.lighthouseFee());

        // Transfer liability security and hold on contract
        ERC20 token = ERC20(liability.token());
        if (liability.cost() > 0)
            token.safeTransferFrom(liability.promisee(),
                                   address(liability),
                                   liability.cost());

        // Transfer validator fee and hold on contract
        if (liability.validator() != address(0) && liability.validatorFee() > 0)
            xrt.safeTransferFrom(liability.promisee(),
                                 address(liability),
                                 liability.validatorFee());
     }

    function liabilityCreated(
        ILiability _liability,
        uint256 _gas
    )
        external
        onlyLighthouse
        gasPriceEstimate
        returns (bool)
    {
        address liability = address(_liability);
        totalGasConsumed         += _gas;
        gasConsumedOf[liability] += _gas;
        return true;
    }

    function liabilityFinalized(
        ILiability _liability,
        uint256 _gas
    )
        external
        onlyLighthouse
        gasPriceEstimate
        returns (bool)
    {
        address liability = address(_liability);
        totalGasConsumed         += _gas;
        gasConsumedOf[liability] += _gas;
        require(xrt.mint(tx.origin, wnFromGas(gasConsumedOf[liability])));
        return true;
    }
}
