pragma solidity ^0.8.4;

import "lib/chainlink-evm/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import "lib/chainlink-evm/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract SimpleLottery is VRFConsumerBaseV2Plus {
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
        _Owner();
        _;
    }

    function _Owner() internal view {
        require(msg.sender == s_owner, "Not owner");
    }

  // Your subscription ID.
  uint256 immutable s_subscriptionId;

  // The gas lane to use, which specifies the maximum gas price to bump to.
  // For a list of available gas lanes on each network,
  // see https://docs.chain.link/docs/vrf-contracts/#configurations
  bytes32 immutable s_keyHash;

  // Depends on the number of requested values that you want sent to the
  // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
  // so 100,000 is a safe default for this example contract. Test and adjust
  // this limit based on the network that you select, the size of the request,
  // and the processing of the callback request in the fulfillRandomWords()
  // function.
  uint32 constant CALLBACK_GAS_LIMIT = 100_000;

  // The default is 3, but you can set this higher.
  uint16 constant REQUEST_CONFIRMATIONS = 3;

  // For this example, retrieve 2 random values in one request.
  // Cannot exceed VRFCoordinatorV2_5.MAX_NUM_WORDS.
  uint32 constant NUM_WORDS = 2;

  uint256[] public s_randomWords;
  uint256 public s_requestId;

  event ReturnedRandomness(uint256[] randomWords);

  /**
   * @notice Constructor inherits VRFConsumerBaseV2Plus
   *
   * @param subscriptionId - the subscription ID that this contract uses for funding requests
   * @param vrfCoordinator - coordinator, check https://docs.chain.link/vrf/v2-5/supported-networks
   * @param keyHash - the gas lane to use, which specifies the maximum gas price to bump to
   */
  constructor(
    uint256 subscriptionId,
    address vrfCoordinator,
    bytes32 keyHash
  ) VRFConsumerBaseV2Plus(vrfCoordinator) {
    s_keyHash = keyHash;
    s_subscriptionId = subscriptionId;
  }

  /**
   * @notice Requests randomness
   * Assumes the subscription is funded sufficiently; "Words" refers to unit of data in Computer Science
   */
  function requestRandomWords() external onlyOwner {
    // Will revert if subscription is not set and funded.
    s_requestId = s_vrfCoordinator.requestRandomWords(
      VRFV2PlusClient.RandomWordsRequest({
        keyHash: s_keyHash,
        subId: s_subscriptionId,
        requestConfirmations: REQUEST_CONFIRMATIONS,
        callbackGasLimit: CALLBACK_GAS_LIMIT,
        numWords: NUM_WORDS,
        extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
      })
    );
  }

  /**
   * @notice Callback function used by VRF Coordinator
   *
   * @param  - id of the request
   * @param randomWords - array of random results from VRF Coordinator
   */
  function fulfillRandomWords(
    uint256,
    /* requestId */
    uint256[] calldata randomWords
  ) internal override {
    s_randomWords = randomWords;
    emit ReturnedRandomness(randomWords);
  }


}
