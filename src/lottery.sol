pragma solidity ^0.8.4;

import {VRFConsumerBaseV2Plus} from "lib/chainlink-evm/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "lib/chainlink-evm/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract SimpleLottery is VRFConsumerBaseV2Plus {
    string public lotName;
    uint256 public lotMaxAmount;
    bool public lotStarted;
    bool public lotRewardsReleased;
    bool public lotFinished;
    bool lotRandomWordsRequestMade;
    address public lotWinner;
    uint256 public lotNonce;

    // stores the data about all tickets boughst.
    mapping(uint256 => address) lotTicketsMapping;

    uint256 public lotRewards;

    // contract owner, the one to take comissions
    address public lotAdmin;

    // Your subscription ID.
    uint256 immutable s_subscriptionId;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 immutable s_keyHash;

    // stores the limit of gas for random words to be received.
    uint32 constant CALLBACK_GAS_LIMIT = 100_000;

    // The default is 3, but you can set this higher.
    uint16 constant REQUEST_CONFIRMATIONS = 3;

    // For this example, retrieve 1 random values in one request.
    // Cannot exceed VRFCoordinatorV2_5.MAX_NUM_WORDS.
    uint32 constant NUM_WORDS = 1;

    //latest random word
    uint256[] public s_randomWords;

    // latest request ID
    uint256 public s_requestId;

    event ReturnedRandomness(uint256[] randomWords);

    /**
     * @notice Constructor inherits VRFConsumerBaseV2Plus
     *
     * @param subscriptionId - the subscription ID that this contract uses for funding requests
     * @param vrfCoordinator - coordinator, check https://docs.chain.link/vrf/v2-5/supported-networks
     * @param keyHash - the gas lane to use, which specifies the maximum gas price to bump to
     */
    constructor(uint256 subscriptionId, address vrfCoordinator, bytes32 keyHash) VRFConsumerBaseV2Plus(vrfCoordinator) {
        s_keyHash = keyHash;
        s_subscriptionId = subscriptionId;
    }

    // let anyone create a new Lottery.
    // it does not run the lottery immediatelly to prevent front-running.
    function createAndStartLottery(string memory _name, uint256 _maxAmount) public payable onlyOwner returns (bool) {
        require(lotStarted == false, "Already started");
        require(_maxAmount < 10000);
        require(msg.value == 0.01 ether, "Send 0.01 ETH to buy ticket");
        lotName = _name;
        lotMaxAmount = _maxAmount;
        lotNonce = 0;
        lotStarted = true;
        return (lotStarted);
    }

    function buyTicket() public payable returns (bool, uint256) {
        require(lotStarted == true, "Not started yet");
        require(msg.value == 0.01 ether, "Send 0.01 ETH to buy ticket");
        lotTicketsMapping[lotNonce] = msg.sender;
        lotNonce++;
        lotRewards += 0.01 ether;
        bool ticketBought_ = true;
        return (ticketBought_, lotNonce);
    }

    function revealRandomWinner() public returns (uint256, address) {
        uint256 s_randomWord_ = s_randomWords[1];
        uint256 result_;
        if (lotNonce > 9) result_ = s_randomWord_ % 10;
        else if (lotNonce > 99) result_ = s_randomWord_ % 100;
        else if (lotNonce > 999) result_ = s_randomWord_ % 1000;
        else result_ = s_randomWord_ % 10000;
        lotWinner = lotTicketsMapping[result_];
        return (result_, lotWinner);
    }

    // Use it to help your friend receive their lottery prizes!
    function releaseRewards() public {
        require(lotRewardsReleased == false, "No rewards");
        (bool sent,) = lotWinner.call{value: lotRewards}("");
        require(sent, "Failed to send Ether");
    }

    function releaseComissions() public onlyOwner {
        require(lotRewardsReleased = true, "Release rewards first");
        (bool sent,) = lotAdmin.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

    /**
     * @notice Requests randomness
     * Assumes the subscription is funded sufficiently; "Words" refers to unit of data in Computer Science
     */
    function requestRandomWords() external {
        require(lotFinished = true, "Not finished yet");
        require(lotRandomWordsRequestMade = false, "Already requested");
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
        lotRandomWordsRequestMade = true;
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
    )
        internal
        override
    {
        s_randomWords = randomWords;
        emit ReturnedRandomness(randomWords);
    }
}
