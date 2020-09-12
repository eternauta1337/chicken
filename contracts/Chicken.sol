pragma solidity ^0.5.16;

import "@openzeppelin/contracts/math/SafeMath.sol";


contract Chicken {
    using SafeMath for uint256;

    uint public poolBalance;

    address public owner;
    address payable public donationAddress;

    event Deposit(address indexed user, uint value);
    event Withdrawal(address indexed user, uint value);

    uint public constant UNIT = 1e18;

    mapping(uint => Game) _games;
    uint public gameIdx;

    struct Game {
        bool finished;
        uint stagingDate; // TODO: Use uint64 to save storage space?
        uint startDate;
        uint endDate;
        uint totalDeposited; // TODO: Rename these? Might be confusing to have such ERC-20-y names
        mapping(address => uint) deposits;
    }

    /* ~~~~~~~~~~~~~~~~~~~~~ MUTATIVE FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~ */

    constructor(address payable pDonationAddress) public {
        require(pDonationAddress != address(0), "Invalid donation address");
        donationAddress = pDonationAddress;

        owner = msg.sender;
    }

    function createGame(
        uint pStagingDate,
        uint pStartDate,
        uint pEndDate
    ) external onlyOwner {
        Game storage game = _getLatestGame();
        require(game.finished, "Last game is still running");

        require(pStagingDate > now, "Invalid staging date");
        require(pStartDate > pStagingDate, "Invalid start date");
        require(pEndDate > pStartDate, "Invalid end date");

        gameIdx += 1;
        Game storage newGame = _games[gameIdx];

        newGame.stagingDate = pStagingDate;
        newGame.startDate = pStartDate;
        newGame.endDate = pEndDate;
    }

    function changeDonationAddress(address payable pDonationAddress) external onlyOwner {
        donationAddress = pDonationAddress;
    }

    function deposit() public payable {
        require(gameIdx > 0, "No active game");

        Game storage game = _getLatestGame();
        require(now > game.stagingDate, "Too early to deposit");
        require(now < game.startDate, "Game already started");

        _mint(msg.sender, msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() public {
        require(gameIdx > 0, "No active game");

        Game storage game = _getLatestGame();
        require(now > game.startDate, "Cannot withdraw until game starts");
        require(now < game.endDate, "Cannot withdraw when game is over");

        uint userBalance = balanceOf(msg.sender);

        (uint withdrawable, uint nonWithdrawable, uint poolReward, uint effectiveAmount) = getExpectedWithdrawal();
        require(address(this).balance >= effectiveAmount, "Insufficient ETH for withdraw");

        msg.sender.transfer(effectiveAmount);

        poolBalance = poolBalance.add(nonWithdrawable).sub(poolReward);

        _burn(msg.sender, userBalance);

        emit Withdrawal(msg.sender, withdrawable);
    }

    function endGame() public {
        require(getTimeElapsedPercent() > UNIT, "Too early to end game");

        Game storage game = _getLatestGame();
        game.finished = true;

        poolBalance = 0;

        donationAddress.transfer(address(this).balance);
    }

    function _mint(address player, uint amount) private {
        Game storage game = _getLatestGame();

        game.deposits[player] = game.deposits[player].add(amount);
        game.totalDeposited = game.totalDeposited.add(amount);
    }

    function _burn(address player, uint amount) private {
        Game storage game = _getLatestGame();

        game.deposits[player] = game.deposits[player].sub(amount);
        game.totalDeposited = game.totalDeposited.sub(amount);
    }

    /* ~~~~~~~~~~~~~~~~~~~~~ VIEW FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~ */

    function balanceOf(address player) public view returns (uint) {
        Game storage game = _getLatestGame();

        return game.deposits[player];
    }

    function getExpectedWithdrawal() public view returns (uint, uint, uint, uint) {
        Game storage game = _getLatestGame();

        uint userBalance = balanceOf(msg.sender);

        uint withdrawable = userBalance.mul(getTimeElapsedPercent()).div(UNIT);
        uint nonWithdrawable = userBalance.sub(withdrawable);

        uint userRatio = userBalance.mul(UNIT).div(game.totalDeposited);
        uint poolReward = poolBalance.mul(userRatio).div(UNIT);

        uint effectiveAmount = withdrawable.add(poolReward);

        return (
            withdrawable,
            nonWithdrawable,
            poolReward,
            effectiveAmount
        );
    }

    function getTimeElapsedPercent() public view returns (uint) {
        Game storage game = _getLatestGame();

        uint timeElapsed = now.sub(game.startDate);

        return timeElapsed.mul(UNIT).div(getGameDuration());
    }

    function getTimeRemainingPercent() public view returns (uint) {
        Game storage game = _getLatestGame();

        uint timeRemaining = game.endDate.sub(now);

        return timeRemaining.mul(UNIT).div(getGameDuration());
    }

    function getGameDuration() public view returns (uint) {
        Game storage game = _getLatestGame();

        return game.endDate.sub(game.startDate);
    }

    function _getLatestGame() private view returns (Game storage) {
        return _games[gameIdx];
    }

    /* ~~~~~~~~~~~~~~~~~~~~~ MODIFIERS ~~~~~~~~~~~~~~~~~~~~~ */

    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner may perform this action");
        _;
    }
}
