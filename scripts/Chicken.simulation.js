const bre = require("@nomiclabs/buidler");

const { now, fastForward, fastForwardTo } = require('../src/utils/timeUtil');

let chicken;
let accounts;

let STAGING_DATE;
let START_DATE;
let END_DATE;

const DONATE_ADDRESS = '0xdEADBeAFdeAdbEafdeadbeafDeAdbEAFdeadbeaf';

async function startStaging() {
  console.log('  Skipping to staging start date...');

  await fastForwardTo(STAGING_DATE + 1);
}

async function simulateDeposits() {
  console.log('  Simulating deposits...');

  for (let i = 0; i < accounts.length; i++) {
    const account = accounts[i];
    const signer = bre.ethers.provider.getSigner(account);

    await chicken.connect(signer).deposit({
      value: bre.ethers.utils.parseEther('1'),
    });

    const bal = await chicken.getPlayerDeposit(account);
    console.log(`    Account[${i}] ${account} deposits ${bre.ethers.utils.formatEther(bal)} ETH`);
  };
}

async function startGame() {
  console.log('  Skipping to game start date...');

  await fastForwardTo(START_DATE + 1);
}

async function simulateWithdrawals() {
  console.log('  Simulating withdrawals...');

  for (let i = 0; i < accounts.length; i++) {
    const skip = 30 * 60 * Math.random();
    await fastForward(skip);

    const timeElapsedPercent = bre.ethers.utils.formatEther(await chicken.getTimeElapsedPercent());
    if (timeElapsedPercent > 1) {
      console.log('    <<< TIME IS UP!!! >>>');
      break;
    }

    const account = accounts[i];
    const signer = bre.ethers.provider.getSigner(account);

    const balanceBefore = await bre.ethers.provider.getBalance(account);

    await chicken.connect(signer).withdraw();

    const balanceAfter = await bre.ethers.provider.getBalance(account);
    const delta = balanceAfter.sub(balanceBefore);

    console.log(`    Account[${i}] ${account} withdraws ${bre.ethers.utils.formatEther(delta)} ETH at game time ${timeElapsedPercent}`);
  };

  const contractBalance = await bre.ethers.provider.getBalance(chicken.address);
  console.log('    Contract balance:', bre.ethers.utils.formatEther(contractBalance));
}

async function endGame() {
  console.log('  Skipping to game end date...');

  await fastForwardTo(END_DATE + 1);

  await chicken.endGame();

  const donateBalance = await bre.ethers.provider.getBalance(DONATE_ADDRESS);
  console.log(`    Donate address balance ${bre.ethers.utils.formatEther(donateBalance)}`);
}

async function main() {
  console.log('Simulating...');

  STAGING_DATE = now() + 10;
  START_DATE = STAGING_DATE + 60 * 60;
  END_DATE = START_DATE + 24 * 60 * 60;

  const Chicken = await ethers.getContractFactory("Chicken");

  chicken = await Chicken.deploy(DONATE_ADDRESS);
  await chicken.createGame(
    STAGING_DATE,
    START_DATE,
    END_DATE
  );

  accounts = await bre.ethers.provider.listAccounts();

  await startStaging();

  await simulateDeposits();

  await startGame();

  await simulateWithdrawals();

  await endGame();
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
