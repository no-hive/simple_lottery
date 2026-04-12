contract SimpleLottery {
    address public admin;
    string public name;
    string public description;
    uint256 public amount_of_tickets;
    uint256 public max_amount;
    bool public started;
    bool public finished;
    address public winner;
    uint256 public ticket_nonce;

    // stores the data about all tickets bought.
    mapping(uint256 => address) tickets;

    // stores the amount of unreleeased owners commisions
    uint256 public commisions;

    // contract owner, the one to take comissions
    address public owner;

    // let anyone create a new Lottery.
    // it does not run the lottery immediatelly to prevent front-running.
    function CreateAndStartLottery(
        uint256 _id_nonce,
        string memory _name,
        uint256 _max_amount,
        uint256 _amount_of_tickets,
        string memory _description
    ) public payable Owner returns (bool) {
        require(started == false, "Already started");
        require(msg.value == 0.01 ether, "Send 0.01 ETH to buy ticket");
        name = _name;
        max_amount = _max_amount;
        amount_of_tickets = 0;
        description = _description;
        started = true;
        // return bool to confirm everything is succeesfull
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
        _addr = winner;
        (bool sent, bytes memory data) = _addr.call{value: i_}("");
        require(sent, "Failed to send Ether");
    }

    function ReleaseComissions() public Owner {
        uint256 i_ = commisions;
        require(i_ > 0, "No comissions");
        commisions = 0;
        (bool sent, bytes memory data) = owner.call{value: i_}("");
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
