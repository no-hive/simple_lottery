
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract SimpleLottery {
    string public s_name;
    uint256 public s_max_amount;
    bool public s_started;
    bool public s_rewards_released;
    bool public s_finished;
    address public s_winner;
    uint256 public s_ticket_nonce;

    // stores the data about all tickets boughst.
    mapping(uint256 => address) s_mapping_tickets;

    uint256 public s_rewards;

    // contract owner, the one to take comissions
    address public s_owner;

    // let anyone create a new Lottery.
    // it does not run the lottery immediatelly to prevent front-running.
    function CreateAndStartLottery(
        string memory _name,
        uint256 _max_amount
    ) public payable Owner returns (bool) {
        require(s_started == false, "Already started");
        require(msg.value == 0.01 ether, "Send 0.01 ETH to buy ticket");
        s_name = _name;
        s_max_amount = _max_amount;
        s_ticket_nonce = 0;
        s_started = true;
        return (s_started);
    }

    function BuyTicket() public payable returns (bool, uint256) {
        require(s_started == true, "Not started yet");
        require(msg.value == 0.01 ether, "Send 0.01 ETH to buy ticket");
        s_mapping_tickets[s_ticket_nonce] = msg.sender;
        s_ticket_nonce++;
        s_rewards += 0.01 ether;
        bool ticket_bought = true;
        return (ticket_bought, s_ticket_nonce);
    }

    function RequestRandomWinner() public returns (uint256, address) {
        require(s_finished = true, "Not finished yet");
        uint256 winner_ticket_ = 1; // here we need to implement chainlink call
        s_winner = s_mapping_tickets[winner_ticket_];
        return (winner_ticket_, s_winner);
    }

    // Use it to help your friend receive their lottery prizes!
    function ReleaseRewards() public {
        require(s_rewards_released == false, "No rewards");
        (bool sent, bytes memory data) = s_winner.call{value: s_rewards}("");
        require(sent, "Failed to send Ether");
    }

    function ReleaseComissions() public Owner {
        require(s_rewards_released = true, "Release rewards first");
        (bool sent, bytes memory data) = s_owner.call{
            value: address(this).balance
        }("");
        require(sent, "Failed to send Ether");
    }

    function ChangeOnwer(address _new_owner) public Owner {
        s_owner = _new_owner;
    }

    modifier Owner() {
        require(msg.sender == s_owner, "Not owner");
        _;
    }
}
