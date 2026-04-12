**This project represents a smart contract that allows to launch a one-time simple lottery.**

1. The contract owner starts the lottery with a self-fee of 0.01 ETH.

2. Anyone can buy a ticket for 0.011 ETH, 0.001 ETH goes to the contract owner and 0.01 goes to the prize pool.

3. The lottery ends either when the maximum number of participants or  specified block is reached.
   
4. Anyone can request the winner to be randmly chosen. 

5. Contract pays the Chainklink oracle fee and find the winner.

6. As soon as the lottery ends, no more lotteries can be done through the same contract.

7. Winner can withdraw the prize pool.

8. Contract owner can withdraw comission earned.

If you want to find the smart contract that allows anyone to start any number of lotteries in one contract with different outcomes, different prize pools, and different time limits - check [lottery_engine](https://github.com/no-hive/lottery_engine), another project of mine.
