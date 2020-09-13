# :chicken: chicken.finance :chicken:
An Ethereum economic game of chicken, designed to harvest greed, and coerce it into good.

### Design
Anyone can create a new game, which consists of a "staging" and a "gameplay" period.

During the staging period, players can deposit ETH for the upcoming game.

During the game, players can withdraw with a penalty defined by the percentage of the game duration that has elapsed. Eg. withdrawing at 50% of the game will only retrieve 50% of the initial deposit. Withdrawing at 99% of the game will retrieve 99% of the initial deposit.

Since this mechanism forfeits fractions of deposits on each withdrawal, a pool is built by early quitters. Successive quitters claim a pro-rata share of the pool when withdrawing. Thus, late quitters may effectively withdraw more than they initially deposited.

![A winner chicken](https://media4.giphy.com/media/fPIo1tm5fokxy/giphy.gif)

At 100% of the game, withdrawals are locked and all remaining funds are donated to Gitcoin grants.

![An unregretful chicken](https://media1.giphy.com/media/5FW7IQuf2eBl6/giphy.gif?cid=ecf05e47lmnn4by4hmleor57fuexdsha8twgqz9vez8f0d5i&rid=giphy.gif)

The game mechanics encourage players to withdraw as late as possible. Concerns about gas prices and race conditions encourage players to withdraw earlier. Failure to withdraw will result in a donation.

### Install
```
npm install
```

### Simulation
Use this command to run a local gameplay simulation.

```
npm run simulate
```
