const bre = require("@nomiclabs/buidler");

let chicken;
let accounts;

async function simulateDeposits() {
  // TODO
}

async function startGame() {
  // TODO
}

async function simulateWithdrawals() {
  // TODO
}

async function endGame() {
  // TODO
}

async function main() {
  const Chicken = await ethers.getContractFactory("Chicken");

  const now = new Date().getTime();
  chicken = await Chicken.deploy(
    now,
    now + 1,
    now + 10,
  );

  accounts = await bre.ethers.provider.listAccounts();

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
