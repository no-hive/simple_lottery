**This project represents a smart contract that allows to launch a one-time simple lottery.**

1. The contract owner starts the lottery buying out very first ticket.

2. Anyone can buy a ticket for 0.01 ETH once lottery is started.

3. 0.008 from each purchase goes to the prize pool, and the rest goes to to cover oracle payments and lottery owner commissions.

3. The lottery ends either when the maximum number of participants reached.
   
4. Anyone can request the winner to be randomly chosen. 

5. Contract (or contract owner via chainlink subscription) pays the Chainklink oracle fee to find the winner.

6. As soon as the lottery ends, no more lotteries can be done through the same contract. 

7. Winner can withdraw the prize pool, or anyone can release the prize for the winner.

8. Contract owner can withdraw earned commission (the remaining balance after the prize pool is released).

If you want to find the smart contract that allows anyone to start any number of lotteries in one contract with different outcomes, different prize pools, and different time limits - check [lottery_engine](https://github.com/no-hive/lottery_engine), another project of mine.
