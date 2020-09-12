pragma solidity ^0.5.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";


contract Chicken is ERC20, ERC20Detailed {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    uint public stagingStartDate;
    uint public gameStartDate;
    uint public gameEndDate;

    uint public forfeitPoolBalance;

    event Deposit(address indexed user, uint value);
    event Withdrawal(address indexed user, uint value);

    uint public constant UNIT = 1e18;

    /* ~~~~~~~~~~~~~~~~~~~~~ MUTATIVE FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~ */

    constructor(
        uint pStagingStartDate,
        uint pGameStartDate,
        uint pGameEndDate
    )
        public
        ERC20Detailed("CHICK Token", "CHK", 18)
    {
        require(pStagingStartDate < pGameStartDate, "Invalid staging start date");
        require(pGameStartDate < pGameEndDate, "Invalid game start date");
        require(pGameEndDate < now, "Invalid game end date");

        stagingStartDate = pStagingStartDate;
        gameStartDate = pGameStartDate;
        gameEndDate = pGameEndDate;
    }

    function deposit() public payable {
        require(now > stagingStartDate, "Too early to deposit");
        require(now < gameStartDate, "Game already started");

        _mint(msg.sender, msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() public {
        require(now > gameStartDate, "Cannot withdraw until game starts");

        uint userBalance = balanceOf(msg.sender);

        uint withdrawableBalance = userBalance.mul(getTimeElapsedPercent()).div(UNIT);

        uint userRatio = userBalance.mul(UNIT).mul(totalSupply);
        uint poolReward = forfeitPoolBalance.mul(userRatio).div(UNIT);
        forfeitPoolBalance = forfeitPoolBalance.sub(poolReward);

        uint effectiveAmount = withdrawableBalance.add(poolReward);
        require(address(this).balance >= effectiveAmount, "Insufficient ETH for withdraw");

        msg.sender.transfer(effectiveAmount);

        uint nonWithdrawableAmount = userBalance.sub(withdrawableBalance);
        forfeitPoolBalance = forfeitPoolBalance.add(nonWithdrawableAmount);

        _burn(msg.sender, userBalance);

        emit Withdrawal(msg.sender, withdrawableBalance);
    }

    function endGame() public {
        require(getTimeElapsedPercent() > UNIT, "Too early to end game");

        // TODO
    }

    /* ~~~~~~~~~~~~~~~~~~~~~ VIEW FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~ */

    function getTimeElapsedPercent() public view returns (uint) {
        uint timeElapsed = now.sub(gameStartDate);

        return timeElapsed.mul(UNIT).div(getGameDuration());
    }

    function getTimeRemainingPercent() public view returns (uint) {
        uint timeRemaining = gameEndDate.sub(now);

        return timeRemaining.mul(UNIT).div(getGameDuration());
    }

    function getGameDuration() public view returns (uint) {
        return gameEndDate.sub(gameStartDate);
    }
}
