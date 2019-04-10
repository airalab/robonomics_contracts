pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/drafts/SignatureBouncer.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';


/// @title Dutch auction contract - distribution of XRT tokens using an auction.
/// @author Stefan George - <stefan.george@consensys.net>
/// @author Airalab - <research@aira.life> 
contract DutchAuction is SignatureBouncer, Ownable {
    using SafeERC20 for ERC20Burnable;

    /*
     *  Events
     */
    event BidSubmission(address indexed sender, uint256 amount);

    /*
     *  Constants
     */
    uint constant public WAITING_PERIOD = 0; // 1 days;

    /*
     *  Storage
     */
    ERC20Burnable public token;
    address public ambix;
    address payable public wallet;
    uint public maxTokenSold;
    uint public ceiling;
    uint public priceFactor;
    uint public startBlock;
    uint public endTime;
    uint public totalReceived;
    uint public finalPrice;
    mapping (address => uint) public bids;
    Stages public stage;

    /*
     *  Enums
     */
    enum Stages {
        AuctionDeployed,
        AuctionSetUp,
        AuctionStarted,
        AuctionEnded,
        TradingStarted
    }

    /*
     *  Modifiers
     */
    modifier atStage(Stages _stage) {
        // Contract on stage
        require(stage == _stage);
        _;
    }

    modifier isValidPayload() {
        require(msg.data.length == 4 || msg.data.length == 164);
        _;
    }

    modifier timedTransitions() {
        if (stage == Stages.AuctionStarted && calcTokenPrice() <= calcStopPrice())
            finalizeAuction();
        if (stage == Stages.AuctionEnded && now > endTime + WAITING_PERIOD)
            stage = Stages.TradingStarted;
        _;
    }

    /*
     *  Public functions
     */
    /// @dev Contract constructor function sets owner.
    /// @param _wallet Multisig wallet.
    /// @param _maxTokenSold Auction token balance.
    /// @param _ceiling Auction ceiling.
    /// @param _priceFactor Auction price factor.
    constructor(address payable _wallet, uint _maxTokenSold, uint _ceiling, uint _priceFactor)
        public
    {
        require(_wallet != address(0) && _ceiling > 0 && _priceFactor > 0);

        wallet = _wallet;
        maxTokenSold = _maxTokenSold;
        ceiling = _ceiling;
        priceFactor = _priceFactor;
        stage = Stages.AuctionDeployed;
    }

    /// @dev Setup function sets external contracts' addresses.
    /// @param _token Token address.
    /// @param _ambix Distillation cube address.
    function setup(ERC20Burnable _token, address _ambix)
        public
        onlyOwner
        atStage(Stages.AuctionDeployed)
    {
        // Validate argument
        require(_token != ERC20Burnable(0) && _ambix != address(0));

        token = _token;
        ambix = _ambix;

        // Validate token balance
        require(token.balanceOf(address(this)) == maxTokenSold);

        stage = Stages.AuctionSetUp;
    }

    /// @dev Starts auction and sets startBlock.
    function startAuction()
        public
        onlyOwner
        atStage(Stages.AuctionSetUp)
    {
        stage = Stages.AuctionStarted;
        startBlock = block.number;
    }

    /// @dev Calculates current token price.
    /// @return Returns token price.
    function calcCurrentTokenPrice()
        public
        timedTransitions
        returns (uint)
    {
        if (stage == Stages.AuctionEnded || stage == Stages.TradingStarted)
            return finalPrice;
        return calcTokenPrice();
    }

    /// @dev Returns correct stage, even if a function with timedTransitions modifier has not yet been called yet.
    /// @return Returns current auction stage.
    function updateStage()
        public
        timedTransitions
        returns (Stages)
    {
        return stage;
    }

    /// @dev Allows to send a bid to the auction.
    /// @param signature KYC approvement
    function bid(bytes calldata signature)
        external
        payable
        isValidPayload
        timedTransitions
        atStage(Stages.AuctionStarted)
        onlyValidSignature(signature)
        returns (uint amount)
    {
        require(msg.value > 0);
        amount = msg.value;

        address payable receiver = msg.sender;

        // Prevent that more than 90% of tokens are sold. Only relevant if cap not reached.
        uint maxWei = maxTokenSold * calcTokenPrice() / 10**9 - totalReceived;
        uint maxWeiBasedOnTotalReceived = ceiling - totalReceived;
        if (maxWeiBasedOnTotalReceived < maxWei)
            maxWei = maxWeiBasedOnTotalReceived;

        // Only invest maximum possible amount.
        if (amount > maxWei) {
            amount = maxWei;
            // Send change back to receiver address.
            receiver.transfer(msg.value - amount);
        }

        // Forward funding to ether wallet
        wallet.transfer(amount);

        bids[receiver] += amount;
        totalReceived += amount;
        emit BidSubmission(receiver, amount);

        // Finalize auction when maxWei reached
        if (amount == maxWei)
            finalizeAuction();
    }

    /// @dev Claims tokens for bidder after auction.
    function claimTokens()
        public
        isValidPayload
        timedTransitions
        atStage(Stages.TradingStarted)
    {
        address receiver = msg.sender;
        uint tokenCount = bids[receiver] * 10**9 / finalPrice;
        bids[receiver] = 0;
        token.safeTransfer(receiver, tokenCount);
    }

    /// @dev Calculates stop price.
    /// @return Returns stop price.
    function calcStopPrice()
        view
        public
        returns (uint)
    {
        return totalReceived * 10**9 / maxTokenSold + 1;
    }

    /// @dev Calculates token price.
    /// @return Returns token price.
    function calcTokenPrice()
        view
        public
        returns (uint)
    {
        return priceFactor * 10**18 / (block.number - startBlock + 7500) + 1;
    }

    /*
     *  Private functions
     */
    function finalizeAuction()
        private
    {
        stage = Stages.AuctionEnded;
        finalPrice = totalReceived == ceiling ? calcTokenPrice() : calcStopPrice();
        uint soldTokens = totalReceived * 10**9 / finalPrice;

        if (totalReceived == ceiling) {
            // Auction contract transfers all unsold tokens to Ambix contract
            token.safeTransfer(ambix, maxTokenSold - soldTokens);
        } else {
            // Auction contract burn all unsold tokens
            token.burn(maxTokenSold - soldTokens);
        }

        endTime = now;
    }
}
