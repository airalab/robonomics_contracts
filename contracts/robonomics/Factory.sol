pragma solidity ^0.4.25;

import 'openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol';

import '../ens/AbstractENS.sol';
import '../ens/AbstractResolver.sol';
import '../misc/SingletonHash.sol';
import '../misc/DutchAuction.sol';
import './interface/IFactory.sol';
import './Lighthouse.sol';
import './Liability.sol';
import './XRT.sol';

contract Factory is IFactory, SingletonHash {
    constructor(
        DutchAuction _auction,
        AbstractENS _ens,
        XRT _xrt
    ) public {
        auction = _auction;
        ens = _ens;
        xrt = _xrt;
    }

    using SafeERC20 for XRT;
    using SafeERC20 for ERC20;

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
    uint256 private constant smmaPeriod = 100;

    /**
     * @dev XRT emission value for utilized gas
     */
    function wnFromGas(uint256 _gas) public view returns (uint256) {
        // Just return wn=gas when auction isn't finish
        if (auction.finalPrice() == 0)
            return _gas;

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

    modifier endGasEstimation(address _liability, uint256 _start_gas) {
        uint256 gas = _start_gas - gasleft();
        require(gas < _start_gas);

        totalGasConsumed          += gas;
        gasConsumedOf[_liability] += gas;

        _;
    }

    function createLighthouse(
        uint256 _minimalStake,
        uint256 _timeoutInBlocks,
        string  _name
    )
        external
        returns (ILighthouse lighthouse)
    {
        bytes32 LIGHTHOUSE_NODE
            // lighthouse.4.robonomics.eth
            = 0xbb02fe616f0926339902db4d17f52c2dfdb337f2a010da2743a8dbdac12d56f9;
        bytes32 hname = keccak256(bytes(_name));

        // Name reservation check
        bytes32 subnode = keccak256(abi.encodePacked(LIGHTHOUSE_NODE, hname));
        require(ens.resolver(subnode) == 0);

        // Create lighthouse
        lighthouse = new Lighthouse(xrt, _minimalStake, _timeoutInBlocks);
        emit NewLighthouse(lighthouse, _name);
        isLighthouse[lighthouse] = true;

        // Register subnode
        ens.setSubnodeOwner(LIGHTHOUSE_NODE, hname, this);

        // Register lighthouse address
        AbstractResolver resolver = AbstractResolver(ens.resolver(LIGHTHOUSE_NODE));
        ens.setResolver(subnode, resolver);
        resolver.setAddr(subnode, lighthouse);
    }

    function createLiability(
        bytes _demand,
        bytes _offer
    )
        external
        onlyLighthouse
        returns (ILiability liability)
    {
        // Create liability
        liability = new Liability(xrt);
        emit NewLiability(liability);

        // Parse messages
        require(address(liability).call(abi.encodePacked(bytes4(0xd9ff764a), _demand))); // liability.demand(...)
        singletonHash(liability.demandHash());

        require(address(liability).call(abi.encodePacked(bytes4(0xd5056962), _offer))); // liability.offer(...)
        singletonHash(liability.offerHash());

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
                                   liability,
                                   liability.cost());

        // Transfer validator fee and hold on contract
        if (liability.validator() != 0 && liability.validatorFee() > 0)
            xrt.safeTransferFrom(liability.promisee(),
                                 liability,
                                 liability.validatorFee());
     }

    function liabilityCreated(
        ILiability _liability,
        uint256 _start_gas
    )
        external
        onlyLighthouse
        gasPriceEstimate
        endGasEstimation(_liability, _start_gas)
        returns (bool)
    {
        return true;
    }

    function liabilityFinalized(
        ILiability _liability,
        uint256 _start_gas
    )
        external
        onlyLighthouse
        gasPriceEstimate
        endGasEstimation(_liability, _start_gas)
        returns (bool)
    {
        require(xrt.mint(tx.origin, wnFromGas(gasConsumedOf[_liability])));
        return true;
    }
}
