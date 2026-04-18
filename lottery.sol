contract SimpleLottery {
    string public s_name;
    uint256 public s_max_amount;
    bool public s_started;
    bool public s_finished;
    address public s_winner;
    uint256 public s_ticket_nonce;

    // stores the data about all tickets bought.
    mapping(uint256 => address) s_mapping_tickets;

    // stores the amount of unreleeased owners commisions
    uint256 public s_commisions;

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

    // Use it to help your friend receive their lottery prizes!
    function ReleaseRewards(address _addr) public {
        uint256 i_ = rewards[_addr];
        require(i_ > 0, "No rewards");
        rewards[_addr] = 0;
        (bool sent, bytes memory data) = _addr.call{value: i_}("");
        require(sent, "Failed to send Ether");
    }

    function BuyTicket() public payable returns (bool) {
        require(started == true, "Not started yet");
        require(msg.value == 0.01 ether, "Send 0.01 ETH to buy ticket");
        address addr_ = msg.sender;
        // update tickets mapping
        // update ticket nonce
        bool ticket_bought = true;
        return (ticket_bought);
    }

    function ChooseRandomWinner(uint256 _id_nonce) internal {
        finished = true;
        // choose random wallet on specific id_nonce. Chainlink Oracle.
        // update user balance = lottery sum
        // update lottery balance = 0
    }

    // Use it to help your friend receive their lottery prizes!
    function ReleaseRewards() public {
        uint256 i_ = rewards;
        require(i_ > 0, "No rewards");
        _addr = s_winner;
        (bool sent, bytes memory data) = _addr.call{value: i_}("");
        require(sent, "Failed to send Ether");
    }

    function ReleaseComissions() public Owner {
        require(s_commissions > 0, "No comissions");
        s_commissions = 0;
        (bool sent, bytes memory data) = owner.call{value: s_commissions}("");
        require(sent, "Failed to send Ether");
    }

    function ChangeOnwer(address _new_owner) public Owner {
        owner = _new_owner;
    }

    modifier Owner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}
