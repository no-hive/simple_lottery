pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import "../src/lottery.sol";
import {VRFCoordinatorV2_5Mock} from "lib/chainlink-evm/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract LotteryTest is Test {
    SimpleLottery public simpleLottery;

    // these two ones are used for
    // 1. deployment
    // 2. CheckConstructorWorkedCorrectly test
    uint256 public DEFAULT_SUBSCRIBTION_ID;

    string TEST_NAME = "HELLO_GAMBLERS";
    uint8 TEST_MAX_CAP = 0;

    uint256 subid_;

    VRFCoordinatorV2_5Mock public vRFCoordinatorV2_5Mock;

    bytes32 immutable KEYHASH = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;

    uint96 immutable _BASEFEE = 100000000000000000;
    uint96 immutable _GASPRICELINK = 1000000000;
    int256 immutable _WEIPERUNITLINK = 3984445400000000;

    address OWNER = address(1);
    address USER = address(2);

    function setUp() public {
        // we create mock OWNER to check that
        // 1. first ticket is really bought out by OWNER
        // 2.Only Owner Functions can be called only by initial OWNER
        vm.startPrank(OWNER);

        vRFCoordinatorV2_5Mock = new VRFCoordinatorV2_5Mock(_BASEFEE, _GASPRICELINK, _WEIPERUNITLINK);

        address VRFCoordinatorV2_5Mock_address = address(vRFCoordinatorV2_5Mock);

        DEFAULT_SUBSCRIBTION_ID = vRFCoordinatorV2_5Mock.createSubscription();

        vRFCoordinatorV2_5Mock.fundSubscription(DEFAULT_SUBSCRIBTION_ID, 100000000000000000000);

        simpleLottery = new SimpleLottery(DEFAULT_SUBSCRIBTION_ID, VRFCoordinatorV2_5Mock_address, KEYHASH);

        address SimpleLottery_address = address(simpleLottery);

        vRFCoordinatorV2_5Mock.addConsumer(DEFAULT_SUBSCRIBTION_ID, SimpleLottery_address);

        vm.stopPrank();
    }

    function testSetUpFunctionSubId() public {
        assertEq(simpleLottery.s_subscriptionId(), DEFAULT_SUBSCRIBTION_ID);
    }

    // 1. need to check if deploy runs correctly
    // 1.1. check addresses somehow + variables that are inscripted via contractor.

    function testConstructorWorkedCorrectly() public {
        assertEq(simpleLottery.s_keyHash(), KEYHASH);
    }

    function testLotteryInitializationWithNotAOwner() public {
        vm.deal(USER, 1 ether);
        vm.startPrank(USER);
        vm.expectRevert();
        simpleLottery.createAndStartLottery{value: 0.01 ether}(TEST_NAME, TEST_MAX_CAP);
        vm.stopPrank();
    }

    function testLotteryInitialization() public {
        vm.startPrank(OWNER);
        vm.deal(OWNER, 1 ether);
        simpleLottery.createAndStartLottery{value: 0.01 ether}(TEST_NAME, TEST_MAX_CAP);
        assertEq(simpleLottery.lotNonce(), 1);
        assertEq(simpleLottery.lotMaxNonce(), 10);
        assertEq(simpleLottery.lotRewards(), 0.008 ether);
        assertEq(simpleLottery.lotName(), TEST_NAME);
        uint256 balance = address(simpleLottery).balance;
        assertEq(balance, 0.01 ether);
        address first_owner = simpleLottery.lotTicketsMapping(0);
        assertEq(first_owner, OWNER);
        vm.stopPrank();
    }

    function testLotteryReinitializationAttempt() public {
        vm.deal(OWNER, 1 ether);
        vm.startPrank(OWNER);
        vm.expectRevert();
        simpleLottery.createAndStartLottery{value: 0.01 ether}("WRONG", TEST_MAX_CAP);
        vm.stopPrank();
    }

    function testLotteryBuyTicket() public {
        vm.deal(USER, 1 ether);
        vm.startPrank(USER);
        simpleLottery.buyTicket();
        uint256 balance = address(simpleLottery).balance;
        assertEq(balance, 0.02 ether);
        assertEq(simpleLottery.lotRewards(), 0.016 ether);
        address user_owner = simpleLottery.lotTicketsMapping(0);
        assertEq(user_owner, USER);
    }
}

// 3. let's check if lottery initizalition really should be payable
// call createAndStartLottery("test_name", 0) + onlyowner
// require
// lotNonce == 0;
// lotMaxNonce == 0;
// lotRewards == 0 ether;
// contract balance == 0

// 4. lets check onlyonwer modifier perfomance=
// call createAndStartLottery("test_name", 0) + payable
// should return (lotStarted = true);
// lotNonce == 0;
// lotMaxNonce == 0;
// lotRewards == 0 ether;
// contract balance == 0

// 5. check all univaliable functions are really unavaliable.

// 6. buy a ticket function loop. tries to get more tickets that are in Nonce.

// 7. check that requestRandomWords works:
// 7.1. call requestRandomWords
// 7.2. add number in oracle contract
// 7.3. check that this word is recieved in lottery contract

// 8. revealRandomWinner

// 9. try to take comissions - must be reverted.

// 10. release rewards for winner.

// 11. owner takes the comissions - must work in a nice way.
