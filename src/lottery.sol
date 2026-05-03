// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// we need both these imports for access to Chainlink VRF true randomness
// that is defintely essential to have a fair on-chain lottery mechanism.
import {VRFConsumerBaseV2Plus} from "lib/chainlink-evm/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "lib/chainlink-evm/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract SimpleLottery is VRFConsumerBaseV2Plus {
    //======================
    // EVENTS
    //======================

    // event emitted after random words are sent back by chainlink.
    event ReturnedRandomness(uint256[] randomWords);

    //======================
    // NO MAGICAL NUMBERS
    //======================

    uint256 public constant TICKET_PRICE = 1e16; // 0.01 ether
    uint256 public constant PRIZE_POOL_SHARE = 8e15; // 0.008 ether

    //======================
    // LOTTERY VARIABLES - BOOLEAN STATUSES
    //======================

    // @notice Indicates whether the lottery has started.
    // Becomes true as lottery admin initizlese the lottery via special function.
    bool public lotStarted;

    // @notice Indicates whether all tickets are sold and lottery is finished.
    // As soon as it is true, no more tickets can be bought and post-lottery functionality is opened.
    bool public lotFinished;

    // @notice Indicates whether a randomness request has been sent to Chainlink VRF.
    bool public lotRandomWordsRequestMade;

    // @notice Indicates whether random words have been received from Chainlink VRF.
    bool public lotRandomWordsRecieved;

    // @notice Indicates whether rewards have been paid out.
    bool public lotRewardsReleased;

    //======================
    // LOTTERY VARIABLES - LOTTERY DATA
    //======================

    // @notice Identifier name of the lottery. Serves as a simple identifier for user or frontend.
    // @dev Not used in any functions beside the lottery initialisation.
    string public lotName;

    // Maximum number of tickets available in the lottery
    // Always will be 10, 100, 1000 or 10000.
    uint256 public lotMaxNonce;

    // @notice The lottery winner address.
    address public lotWinner;

    // @notice Total number of tickets sold.
    uint256 public lotNonce;

    // @notice Mapping of ticket index to buyer address.
    // @dev ticketId => buyer, where ticketId = curren lotNonce.
    mapping(uint256 => address) public lotTicketsMapping;

    // @notice Total reward pool available to the winner.
    // @dev 80% of each ticket purchase is added here.
    uint256 public lotRewards;

    //======================
    // RANDOMNESS CONSTANTS
    //======================

    // @notice Chainlink VRF subscription ID.
    uint256 public s_subscriptionId;

    // @notice Gas lane key hash used for VRF requests.
    bytes32 public immutable s_keyHash;

    // @notice Gas limit for VRF callback.
    uint32 constant CALLBACK_GAS_LIMIT = 1e5;

    // @notice Number of confirmations before VRF response.
    uint16 constant REQUEST_CONFIRMATIONS = 3;

    // @notice Number of random words requested.
    uint32 constant NUM_WORDS = 1;

    //======================
    // RANDOMNESS VARIABLES
    //======================

    //Last received random words.
    // used to calculate the winner ticket id.
    uint256[] public s_randomWords;

    // @notice Last VRF request ID
    // considering this contract can be used only for one lottery,
    // the very first VRF request will be always the last one,
    // as after it the function call that updates this variable is blocked.
    uint256 public s_requestId;

    //======================
    // CONSTRUCTOR
    //======================

    // @notice Constructor inherits VRFConsumerBaseV2Plus.
    // @param subscriptionId - the subscription ID that this contract uses for funding requests.
    // @param vrfCoordinator - coordinator, check https://docs.chain.link/vrf/v2-5/supported-networks.
    // @param keyHash - the gas lane to use, which specifies the maximum gas price to bump to.
    constructor(uint256 subscriptionId, address vrfCoordinator, bytes32 keyHash) VRFConsumerBaseV2Plus(vrfCoordinator) {
        s_keyHash = keyHash;
        s_subscriptionId = subscriptionId;
    }

    //======================
    // FUNCTIONS - START LOTTERY FUNCTIONS
    //======================

    // let contract administrator create a new Lottery.
    // to start a lottery admin als oneeds to buy out the very first ticket.
    function createAndStartLottery(string memory _name, uint8 _maxTicketAmountOption)
        public
        payable
        onlyOwner
        returns (bool, bool, uint256)
    {
        require(!lotStarted, "Already started");
        require(msg.value == TICKET_PRICE, "Send 0.01 ETH to buy out the first ticket");
        if (_maxTicketAmountOption == 0) lotMaxNonce = 10;
        else if (_maxTicketAmountOption == 1) lotMaxNonce = 100;
        else if (_maxTicketAmountOption == 2) lotMaxNonce = 1000;
        else lotMaxNonce = 10000;
        lotName = _name;
        lotNonce = 0;
        lotStarted = true;
        (bool ticketBought_, uint256 lotNonce_) = buyTicket_();
        return (lotStarted, ticketBought_, lotNonce_);
    }

    // internal versoin of buy ticket so lottery owner can buy out the first ticket with the lottery deployment.
    function buyTicket_() internal returns (bool, uint256) {
        require(lotStarted, "Not started yet");
        require(!lotFinished, "Already finished");
        lotTicketsMapping[lotNonce] = msg.sender;
        lotNonce++;
        lotRewards += PRIZE_POOL_SHARE; // only 80% of ticket price is written down - other goes to comissions.
        bool ticketBought_ = true;
        if (lotMaxNonce == lotNonce) {
            lotFinished = true;
            return (ticketBought_, lotNonce);
        } else {
            return (ticketBought_, lotNonce);
        }
    }

    //======================
    // FUNCTIONS - LOTTERY IS LIVE
    //======================

    // the function that allows user to participate in the lottery
    // user can buy any amount of tickets, increasing the chances to win accordingly.
    function buyTicket() public payable returns (bool, uint256) {
        require(lotStarted, "Not started yet");
        require(!lotFinished, "Already finished");
        require(msg.value == TICKET_PRICE, "Send 0.01 ETH to buy ticket");
        lotTicketsMapping[lotNonce] = msg.sender;
        lotNonce++;
        lotRewards += PRIZE_POOL_SHARE; // only 80% of ticket price is written down - other goes to comissions.
        bool ticketBought_ = true;
        if (lotMaxNonce == lotNonce) {
            lotFinished = true;
            return (ticketBought_, lotNonce);
        } else {
            return (ticketBought_, lotNonce);
        }
    }

    //======================
    // FUNCTIONS - FIND THE WINNER
    //======================

    // @notice Requests randomness
    // Assumes the subscription is funded sufficiently; "Words" refers to unit of data in Computer Science
    // as soon as lottery ends, anyone can initiate this function to run a chainlink request.
    // due to lotRandomWordsRequestMade this function can be run only once on the entire contract life cycle.
    function requestRandomWords() public {
        require(lotFinished, "Not finished yet");
        require(!lotRandomWordsRequestMade, "Already requested");
        lotRandomWordsRequestMade = true;
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

    // after the random words are got, anyone can call this function
    // once it's called, the winner is officially found and can withdraw the rewards.
    function revealRandomWinner() public returns (uint256, address) {
        require(lotRandomWordsRecieved, "No oracle answer yet");
        uint256 s_randomWord_ = s_randomWords[1];
        uint256 result_;
        if (lotNonce == 10) result_ = s_randomWord_ % 10;
        else if (lotNonce == 100) result_ = s_randomWord_ % 100;
        else if (lotNonce == 1000) result_ = s_randomWord_ % 1000;
        else result_ = s_randomWord_ % 10000;
        lotWinner = lotTicketsMapping[result_];
        return (result_, lotWinner);
    }

    //======================
    // FUNCTIONS - MANAGE CONTRACT POST_LOTTERY BALANCE
    //======================

    // Use it to help your friend receive their lottery prizes!
    // or release it on your own if you are the lucky one!
    // also use it if you are the greedy admin that wants your comissions to be unlocked
    // after winner takes their part.
    function releaseRewards() public {
        require(!lotRewardsReleased, "No rewards");
        (bool sent,) = lotWinner.call{value: lotRewards}("");
        require(sent, "Failed to send Ether");
    }

    // as soon as winners rewards released, owner takes the request.
    // the machanism to take EVERYBTHING ELSE not the written down sum is
    // designed also to work if chainlink orcale is switched to self-sponsored machamism
    // in this case, this comission will be first used to pay for orcale call
    // and only then the owner can take the rest
    function releaseComissions() public onlyOwner {
        require(lotRewardsReleased, "Release rewards first");
        (bool sent,) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send Ether");
    }
}
