# :chicken: chicken.finance :chicken:
An Ethereum economic game of chicken, designed to harvest greed, and coerce it into good.

### Design
Anyone can create a new game, which consists of a "staging" and a "gameplay" period.

During the staging period, players can deposit ETH for the upcoming game.

During the game, players can withdraw with a penalty defined by the percentage of the game duration that has elapsed. Eg. withdrawing at 50% of the game will only retrieve 50% of the initial deposit. Withdrawing at 99% of the game will retrieve 99% of the initial deposit.

Since this mechanism forfeits fractions of deposits on each withdrawal, a pool is built by early quitters. Successive quitters claim a pro-rata share of the pool when withdrawing. Thus, late quitters may effectively withdraw more than they initially deposited.

At 100% of the game, withdrawals are locked and all remaining funds are donated to Gitcoin.

This mechanism encourages people withdraw as late as possible. Participants will have to make a decision on when to withdraw, which is not trivial. Concerns about gas prices and race conditions might encourage participants to withdraw earlier.

### Install
```
npm install
```

### Simulation
Use this command to run a local gameplay simulation.

```
npm run simulate
```
