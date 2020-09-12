# chicken :chicken:
An Ethereum economic game designed to harvest greed and coerce it into a common good.

### design
Participants may purchase $CHICK tokens in a given time window at the start of the game. Price is fixed to 1 ETH = 1 CHICK, so, CHICK is in a way similar to wrapped ETH. CHICK is transferable and fully ERC20 compatible. After entry, the game plays out for N days, after which all the ETH backing up CHICK will be donated to Gitcoin, and CHICK will effectively become worthless.

However, participants may withdraw their ETH before such an event, but will only be able to withdraw a portion of their balance depending on the time of exit. For example, if a participant withdraws at 50% of game time, he/she will only be able to withdraw 50% of their initial deposit. If withdrawal occurs at 25% of game time, only 25% will be withdrawn. Thus, participants that withdraw early (before t = 1) donate to a common pool. Now, whenever someone withdraws, they get a portion of their entry collateral as described above, but they also get a pro-rata portion of the common pool.

This mechanism encourages people to not withdraw early, but also encourages them to withdraw before the end date. Participants will have to make a decision on when to withdraw, which is not trivial. Concerns about gas prices and race conditions might encourage participants to withdraw so much earlier. In the end, game mechanics will reward participants that manage to hold as late as possible, but not too late.

### install
```
npm install
```

### simulation
Run this command to run a local gameplay simulation.

```
npm run simulate
```
