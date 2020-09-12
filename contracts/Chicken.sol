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

    event Deposit(address indexed user, uint value);
    event Withdraw(address indexed user, uint value);

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

        balances[msg.sender] = balances[msg.sender].add(msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint pAmount) public {
        // TODO
    }

    function endGame() public {
        require(timeElapsedPercent() > UNIT, "Too early to end game");

        // TODO
    }

    /* ~~~~~~~~~~~~~~~~~~~~~ VIEW FUNCTIONS ~~~~~~~~~~~~~~~~~~~~~ */

    function timeElapsedPercent() public view returns (uint) {
        uint timeElapsed = now.sub(gameStartDate);

        return timeElapsed.mul(UNIT).div(gameDuration());
    }

    function timeRemainingPercent() public view returns (uint) {
        uint timeRemaining = gameEndDate.sub(now);

        return timeRemaining.mul(UNIT).div(gameDuration());
    }

    function gameDuration() public view returns (uint) {
        return gameEndDate.sub(gameStartDate);
    }
}
