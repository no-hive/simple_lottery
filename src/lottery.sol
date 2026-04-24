// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {VRFConsumerBaseV2Plus} from "lib/chainlink-evm/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "lib/chainlink-evm/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract SimpleLottery is VRFConsumerBaseV2Plus {
    // @notice Identifier name of the lottery.
    // lottery name. serves as a simple identifier for user.
    // @dev Not used in any functions beside the lottery initialisation.
    string public lotName;

    // the max amount of tickets to be bought;
    uint256 public lotMaxNonce;

    // @notice Indicates whether lottery has started
    // @dev Updated in ___ function
    bool public lotStarted;

    // @notice Indicates whether lottery is finished
    // @dev Updated in ___ function
    bool public lotFinished;

    // @notice Indicates whether VRF request was already made
    // @dev Updated in ___ function
    bool public lotRandomWordsRequestMade;

    // @notice Indicates whether Chainlink oracle has sent the random words back
    // @dev Updated in __ function
    bool public lotRandomWordsRecieved;

    // @notice Indicates whether rewards were already released
    // @dev Updated in ___ function
    bool public lotRewardsReleased;

    // @notice The lottery winner address. This address is only allowed to withdraw rewards.
    // @dev Found out in two steps:
    // 1.
    // 2.
    address public lotWinner;

    // @notice the amount of tickets bout for lottery participation.
    // @udev used at:
    // 1.
    // 2.
    uint256 public lotNonce;

    // @notice Mapping from ticket index to buyer address.
    // @dev Ticket index = lotNonce in the moment of ticket purchase.
    mapping(uint256 => address) lotTicketsMapping;

    // @notice the Rewards the winner can withdraw once lottery is ended and winner is found.
    // @dev sum updated in __ function each time someone buys a ticket.
    uint256 public lotRewards;

    // @notice contract owner, the one to take comissions.
    // @dev the equiwalent of contract owner.
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

    // event emitted after random words are sent back by chainlink
    event ReturnedRandomness(uint256[] randomWords);

    // @notice Constructor inherits VRFConsumerBaseV2Plus
    // @param subscriptionId - the subscription ID that this contract uses for funding requests
    // @param vrfCoordinator - coordinator, check https://docs.chain.link/vrf/v2-5/supported-networks
    // @param keyHash - the gas lane to use, which specifies the maximum gas price to bump to
    constructor(uint256 subscriptionId, address vrfCoordinator, bytes32 keyHash) VRFConsumerBaseV2Plus(vrfCoordinator) {
        s_keyHash = keyHash;
        s_subscriptionId = subscriptionId;
    }

    // let contract administrator create a new Lottery.
    // to start a lottery admin als oneeds to buy out the very first ticket.
    function createAndStartLottery(string memory _name, uint256 _maxNonce) public payable onlyOwner returns (bool) {
        require(lotStarted == false, "Already started");
        require(_maxNonce < 10000);
        require(msg.value == 0.01 ether, "Send 0.01 ETH to buy ticket");
        lotName = _name;
        lotMaxNonce = _maxNonce;
        lotNonce = 0;
        lotStarted = true;
        return (lotStarted);
    }

    // the function that allows user to participate in the lottery
    // user can buy any amount of tickets, increasing the chances to win accordingly.
    function buyTicket() public payable returns (bool, uint256) {
        require(lotStarted == true, "Not started yet");
        require(msg.value == 0.01 ether, "Send 0.01 ETH to buy ticket");
        lotTicketsMapping[lotNonce] = msg.sender;
        lotNonce++;
        lotRewards += 0.01 ether;
        bool ticketBought_ = true;
        return (ticketBought_, lotNonce);
    }

    // after the random words are got, anyone can call this function
    // once it's called, the winner is officially found and can withdraw the rewards.
    function revealRandomWinner() public returns (uint256, address) {
        require(lotRandomWordsRequestMade = false, "Already requested");
        uint256 s_randomWord_ = s_randomWords[1];
        uint256 result_;
        if (lotNonce < 9) result_ = s_randomWord_ % 10;
        else if (lotNonce < 99) result_ = s_randomWord_ % 100;
        else if (lotNonce < 999) result_ = s_randomWord_ % 1000;
        else result_ = s_randomWord_ % 10000;
        lotWinner = lotTicketsMapping[result_];
        return (result_, lotWinner);
    }

    // Use it to help your friend receive their lottery prizes!
    // or release it on your own if you are the lucky one!
    // also use it if you are the greedy admin that wants your comissions to be unlocked
    // after winner takes their part.
    function releaseRewards() public {
        require(lotRewardsReleased == false, "No rewards");
        (bool sent,) = lotWinner.call{value: lotRewards}("");
        require(sent, "Failed to send Ether");
    }

    // as soon as winners rewards released, owner takes the request.
    // the machanism to take EVERYBTHING ELSE not the written down sum is
    // designed also to work if chainlink orcale is switched to self-sponsored machamism
    // in this case, this comission will be first used to pay for orcale call
    // and only then the owner can take the rest
    function releaseComissions() public onlyOwner {
        require(lotRewardsReleased = true, "Release rewards first");
        (bool sent,) = lotAdmin.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }

    // @notice Requests randomness
    // Assumes the subscription is funded sufficiently; "Words" refers to unit of data in Computer Science
    // as soon as lottery ends, anyone can initiate this function to run a chainlink request.
    // due to lotRandomWordsRequestMade this function can be run only once on the entire contract life cycle.
    function requestRandomWords() public {
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

    // @notice Callback function used by VRF Coordinator
    // @param  - id of the request
    // @param randomWords - array of random results from VRF Coordinator
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
        lotRandomWordsRecieved = true;
    }
}
