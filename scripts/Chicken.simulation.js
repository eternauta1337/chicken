const bre = require("@nomiclabs/buidler");

const { fastForward } = require('../src/utils/skipTime');

let chicken;
let accounts;

const NOW = Math.floor(new Date().getTime() / 1000);
const STAGING_START_DATE = NOW + 10;
const GAME_START_DATE = STAGING_START_DATE + 60 * 60;
const GAME_END_DATE = GAME_START_DATE + 24 * 60 * 60;

async function startStaging() {
  console.log('  Skipping to staging start date...');

  await fastForward(STAGING_START_DATE - NOW + 1);
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
  // TODO
}

async function simulateWithdrawals() {
  console.log('  Simulating withdrawals...');
  // TODO
}

async function endGame() {
  console.log('  Skipping to game end date...');
  // TODO
}

async function main() {
  console.log('Simulating...');

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
