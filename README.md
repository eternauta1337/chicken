# :chicken: chicken.finance :chicken:
An Ethereum economic game designed to harvest greed, and coerce it into a common good.

### design
Anyone can create a new game, which consists of a "staging" and a "gameplay" period.

During the staging period, players can deposit ETH for the upcoming game.

During the game, players can withdraw with a penalty defined by the percentage of the game duration that has elapsed. Eg. withdrawing at 50% of the game duration will only withdraw 50% of the initial deposit. Full deposits will only be available when the game ends.

However, since this mechanism forfeits fractions of deposits, a pool is built by early quitters, and successive quitters will be able to claim a pro-rata share of the pool when withdrawing. Thus, late quitters may effectively be able to withdraw more than they initially deposited.

When a game ends, withdrawals are locked and all remaining funds are donated to Gitcoin.

This mechanism encourages people withdraw as late as possible. Participants will have to make a decision on when to withdraw, which is not trivial. Concerns about gas prices and race conditions might encourage participants to withdraw earlier.

### install
```
npm install
```

### simulation
Run this command to run a local gameplay simulation.

```
npm run simulate
```
