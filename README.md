
![License](https://img.shields.io/github/license/no-hive/simple_lottery?style=flat) 
![Last Commit](https://img.shields.io/github/last-commit/no-hive/simple_lottery?style=flat) 
![Commit Count](https://img.shields.io/github/commit-activity/t/no-hive/simple_lottery?style=flat) 
![Tests](https://github.com/no-hive/simple_lottery/actions/workflows/tests.yml/badge.svg) 

## Simple lottery smart contract with Chainlink VRF integrated

---

#### Use it to conduct a one-time lottery with really simple rules. Explore the functionality below:

#### 🎟️ Starting & buying tickets
1. The **contract owner** starts the lottery by purchasing the very first ticket.
2. Once started, **anyone can buy a ticket** for `0.01 ETH`.
3. Of each purchase, `0.008 ETH` goes to the **prize pool**; the rest covers the **oracle fee** and **owner commission**.

#### 🏁 Ending the lottery
4. The lottery **ends** once the maximum number of tickets is sold.
5. After that, **no new lottery** can be started through the same contract.

#### 🎲 Picking the winner
6. Once the ticket cap is reached, **anyone can request** a randomly chosen winner.
7. The contract (or the owner, via a Chainlink subscription) **pays the Chainlink VRF fee** to determine the winner.

#### 💰 Payouts
8. The **winner** can withdraw the prize pool — or anyone can release it on their behalf.
9. The **contract owner** can withdraw the earned commission (balance remaining after the prize pool is released).

---

> [!WARNING]
> **This project is educational. Use it with real money only at your own risk.**
