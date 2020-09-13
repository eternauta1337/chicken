pragma solidity ^0.5.16;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


contract Chicken is ReentrancyGuard {
    using SafeMath for uint256;

    address payable public owner;
    address payable public donationAddress;

    event Deposit(address indexed player, uint value);
    event Withdrawal(address indexed player, uint value);

    uint public constant UNIT = 1e18;

    mapping(uint => mapping(address => uint)) _deposits;
    uint public gameIdx;

    uint public stagingDate; // TODO: Use uint64 to save storage space?
    uint public startDate;
    uint public endDate;
    uint public totalDeposited;
    uint public poolBalance;

    /* ~~~~~~~~~~~~~~~~~~~~~ MUTATIVE FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~ */

    constructor(address payable pDonationAddress) public {
        _setDonationAddress(pDonationAddress);

        owner = msg.sender;
    }

    function createGame(
        uint pStagingDate,
        uint pStartDate,
        uint pEndDate
    ) external {
        require(endDate == 0, "Game is running");

        require(pStagingDate > now, "Invalid staging date");
        require(pStartDate > pStagingDate, "Invalid start date");
        require(pEndDate > pStartDate, "Invalid end date");

        gameIdx += 1;

        stagingDate = pStagingDate;
        startDate = pStartDate;
        endDate = pEndDate;
    }

    function setDonationAddress(address payable pDonationAddress) external onlyOwner {
        _setDonationAddress(pDonationAddress);
    }

    function _setDonationAddress(address payable pDonationAddress) private {
        require(pDonationAddress != address(0), "Invalid donation address");

        donationAddress = pDonationAddress;
    }

    function deposit() public payable {
        require(endDate > 0, "No active game");

        require(now > stagingDate, "Too early to deposit");
        require(now < startDate, "Game already started");

        mapping(address => uint) storage deposits = _deposits[gameIdx];
        deposits[msg.sender] = deposits[msg.sender].add(msg.value);
        totalDeposited = totalDeposited.add(msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() public nonReentrant {
        require(endDate > 0, "No active game");

        require(now > startDate, "Cannot withdraw until game starts");
        require(now < endDate, "Cannot withdraw when game is over");

        uint playerDeposit = getPlayerDeposit(msg.sender);

        (uint withdrawable, uint nonWithdrawable) = getPlayerWithdrawable(msg.sender);

        uint poolShare = getPlayerPoolShare(msg.sender);

        poolBalance = poolBalance.add(nonWithdrawable).sub(poolShare);

        mapping(address => uint) storage deposits = _deposits[gameIdx];
        deposits[msg.sender] = deposits[msg.sender].sub(playerDeposit);
        totalDeposited = totalDeposited.sub(playerDeposit);

        uint effectiveWithdrawal = withdrawable.add(poolShare);
        msg.sender.transfer(effectiveWithdrawal);

        emit Withdrawal(msg.sender, effectiveWithdrawal);
    }

    function endGame() public nonReentrant {
        require(endDate > 0, "No active game");
        require(now > endDate, "Too early to end game");

        _resetGame();

        uint balance = address(this).balance;
        if (balance > 0) {
            // Donate 99.9% of the balance.
            uint donated = balance.mul(999).div(10000);
            donationAddress.transfer(donated);

            // 0.1% as owner fees.
            owner.transfer(address(this).balance);
        }
    }

    function _resetGame() private {
        stagingDate = startDate = endDate = 0;
        poolBalance = 0;
        totalDeposited = 0;
    }

    /* ~~~~~~~~~~~~~~~~~~~~~ VIEW FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~ */

    function getPlayerDeposit(address player) public view returns (uint) {
        mapping(address => uint) storage deposits = _deposits[gameIdx];

        return deposits[player];
    }

    function getPlayerWithdrawable(address player) public view returns (uint, uint) {
        uint playerDeposit = getPlayerDeposit(player);

        uint withdrawable = playerDeposit.mul(getTimeElapsedPercent()).div(UNIT);
        uint nonWithdrawable = playerDeposit.sub(withdrawable);

        return (withdrawable, nonWithdrawable);
    }

    function getPlayerPoolShare(address player) public view returns (uint) {
        uint playerDeposit = getPlayerDeposit(player);

        uint playerDepositRatio = playerDeposit.mul(UNIT).div(totalDeposited);

        return poolBalance.mul(playerDepositRatio).div(UNIT);
    }

    function getExpectedWithdrawal(address player) public view returns (uint) {
        (uint withdrawable,) = getPlayerWithdrawable(player);

        uint poolShare = getPlayerPoolShare(player);

        return withdrawable.add(poolShare);
    }

    function getTimeElapsedPercent() public view returns (uint) {
        uint timeElapsed = now.sub(startDate);

        return timeElapsed.mul(UNIT).div(getGameDuration());
    }

    function getTimeRemainingPercent() public view returns (uint) {
        uint timeRemaining = endDate.sub(now);

        return timeRemaining.mul(UNIT).div(getGameDuration());
    }

    function getGameDuration() public view returns (uint) {
        return endDate.sub(startDate);
    }

    /* ~~~~~~~~~~~~~~~~~~~~~ MODIFIERS ~~~~~~~~~~~~~~~~~~~~~ */

    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner may perform this action");
        _;
    }
}
