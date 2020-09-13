pragma solidity ^0.5.16;

import "@openzeppelin/contracts/math/SafeMath.sol";


contract Chicken {
    using SafeMath for uint256;

    address public owner;
    address payable public donationAddress;

    event Deposit(address indexed player, uint value);
    event Withdrawal(address indexed player, uint value);

    uint public constant UNIT = 1e18;

    mapping(uint => Game) _games;
    uint public gameIdx;

    struct Game {
        bool finished;
        uint stagingDate; // TODO: Use uint64 to save storage space?
        uint startDate;
        uint endDate;
        uint totalDeposited;
        uint poolBalance;
        mapping(address => uint) deposits;
    }

    /* ~~~~~~~~~~~~~~~~~~~~~ MUTATIVE FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~ */

    constructor(address payable pDonationAddress) public {
        _setDonationAddress(pDonationAddress);

        owner = msg.sender;
    }

    function createGame(
        uint pStagingDate,
        uint pStartDate,
        uint pEndDate
    ) external onlyOwner {
        require(pStagingDate > now, "Invalid staging date");
        require(pStartDate > pStagingDate, "Invalid start date");
        require(pEndDate > pStartDate, "Invalid end date");

        if (gameIdx > 0) {
            Game storage game = _getLatestGame();
            require(game.finished, "Last game is still running");
        }

        gameIdx += 1;
        Game storage newGame = _games[gameIdx];

        newGame.stagingDate = pStagingDate;
        newGame.startDate = pStartDate;
        newGame.endDate = pEndDate;
    }

    function setDonationAddress(address payable pDonationAddress) external onlyOwner {
        _setDonationAddress(pDonationAddress);
    }

    function _setDonationAddress(address payable pDonationAddress) private {
        require(pDonationAddress != address(0), "Invalid donation address");

        donationAddress = pDonationAddress;
    }

    function deposit() public payable {
        require(gameIdx > 0, "No active game");

        Game storage game = _getLatestGame();
        require(now > game.stagingDate, "Too early to deposit");
        require(now < game.startDate, "Game already started");

        game.deposits[msg.sender] = game.deposits[msg.sender].add(msg.value);
        game.totalDeposited = game.totalDeposited.add(msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() public {
        require(gameIdx > 0, "No active game");

        Game storage game = _getLatestGame();
        require(now > game.startDate, "Cannot withdraw until game starts");
        require(now < game.endDate, "Cannot withdraw when game is over");

        uint playerDeposit = getPlayerDeposit(msg.sender);

        (uint withdrawable, uint nonWithdrawable) = getPlayerWithdrawable(msg.sender);

        uint poolShare = getPlayerPoolShare(msg.sender);

        game.poolBalance = game.poolBalance.add(nonWithdrawable).sub(poolShare);

        game.deposits[msg.sender] = game.deposits[msg.sender].sub(playerDeposit);
        game.totalDeposited = game.totalDeposited.sub(playerDeposit);

        uint effectiveWithdrawal = withdrawable.add(poolShare);
        msg.sender.transfer(effectiveWithdrawal);

        emit Withdrawal(msg.sender, effectiveWithdrawal);
    }

    function endGame() public {
        require(getTimeElapsedPercent() > UNIT, "Too early to end game");

        Game storage game = _getLatestGame();
        game.finished = true;

        donationAddress.transfer(address(this).balance);
    }

    /* ~~~~~~~~~~~~~~~~~~~~~ VIEW FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~ */

    function getPlayerDeposit(address player) public view returns (uint) {
        Game storage game = _getLatestGame();

        return game.deposits[player];
    }

    function getPlayerWithdrawable(address player) public view returns (uint, uint) {
        Game storage game = _getLatestGame();

        uint playerDeposit = game.deposits[player];

        uint withdrawable = playerDeposit.mul(getTimeElapsedPercent()).div(UNIT);
        uint nonWithdrawable = playerDeposit.sub(withdrawable);

        return (withdrawable, nonWithdrawable);
    }

    function getPlayerPoolShare(address player) public view returns (uint) {
        Game storage game = _getLatestGame();

        uint playerDeposit = game.deposits[player];

        uint playerDepositRatio = playerDeposit.mul(UNIT).div(game.totalDeposited);

        return game.poolBalance.mul(playerDepositRatio).div(UNIT);
    }

    function getExpectedWithdrawal(address player) public view returns (uint) {
        (uint withdrawable,) = getPlayerWithdrawable(player);

        uint poolShare = getPlayerPoolShare(player);

        return withdrawable.add(poolShare);
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
