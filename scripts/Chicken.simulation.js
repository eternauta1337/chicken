const bre = require("@nomiclabs/buidler");

const { now, fastForwardTo } = require('../src/utils/timeUtil');

let chicken;
let accounts;

let STAGING_START_DATE;
let GAME_START_DATE;
let GAME_END_DATE;

async function startStaging() {
  console.log('  Skipping to staging start date...');

  await fastForwardTo(STAGING_START_DATE + 1);
}

async function simulateDeposits() {
  console.log('  Simulating deposits...');

  for (let i = 0; i < accounts.length; i++) {
    const account = accounts[i];
    const signer = bre.ethers.provider.getSigner(account);

    await chicken.connect(signer).deposit({
      value: bre.ethers.utils.parseEther('1'),
    });

    const bal = await chicken.balanceOf(account);
    console.log(`    Account[${i}] ${account} deposit:`, bal.toString());
  };
}

async function startGame() {
  console.log('  Skipping to game start date...');

  await fastForwardTo(GAME_START_DATE + 1);
}

async function simulateWithdrawals() {
  console.log('  Simulating withdrawals...');
  // TODO
}

async function endGame() {
  console.log('  Skipping to game end date...');

  await fastForwardTo(GAME_END_DATE + 1);
}

async function main() {
  console.log('Simulating...');

  STAGING_START_DATE = now() + 10;
  GAME_START_DATE = STAGING_START_DATE + 60 * 60;
  GAME_END_DATE = GAME_START_DATE + 24 * 60 * 60;

  const Chicken = await ethers.getContractFactory("Chicken");

  chicken = await Chicken.deploy(
    STAGING_START_DATE,
    GAME_START_DATE,
    GAME_END_DATE,
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
