pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import "../src/lottery.sol";
import {VRFCoordinatorV2_5Mock} from "lib/chainlink-evm/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract LotteryTest is Test {
    SimpleLottery simpleLottery;

    // these two ones are used for
    // 1. deployment
    // 2. CheckConstructorWorkedCorrectly test
    uint256 immutable DEFAULT_SUBSCRIBTION_ID;
    bytes32 immutable DEFAULT_KEYHASH;

    // these ones are used to initialise test lottery
    // tring memory _name = "HELLO_GAMBLERS"
    //uint8 _maxTicketAmountOption = 1

    VRFCoordinatorV2_5Mock public vRFCoordinatorV2_5Mock;

    bytes32 immutable KEYHASH = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;

    uint96 immutable _BASEFEE = 100000000000000000;
    uint96 immutable _GASPRICELINK = 1000000000;
    int256 immutable _WEIPERUNITLINK = 3984445400000000;

    function setUp() public {
        vRFCoordinatorV2_5Mock = new VRFCoordinatorV2_5Mock(_BASEFEE, _GASPRICELINK, _WEIPERUNITLINK);

        address VRFCoordinatorV2_5Mock_address = address(vRFCoordinatorV2_5Mock);

        uint256 _subid = vRFCoordinatorV2_5Mock.createSubscription();

        vRFCoordinatorV2_5Mock.fundSubscription(_subid, 100000000000000000000);

        simpleLottery = new SimpleLottery(_subid, VRFCoordinatorV2_5Mock_address, KEYHASH);

        address SimpleLottery_address = address(simpleLottery);

        vRFCoordinatorV2_5Mock.addConsumer(_subid, SimpleLottery_address);
    }

    // 1. need to check if deploy runs correctly
    // 1.1. check addresses somehow + variables that are inscripted via contractor.

    function testConstructorWorkedCorrectly() public {
        assertEq(simpleLottery.s_keyHash(), KEYHASH);
    }
}

// function CheckLotteryInitializationWorks () {
// assertEq (CONTRACT.createAndStartLottery(TEST_NAME, TEST_AMOUNT),(true, true, 1));
// assertEq (CONTRACT.lotNonce(), 1);
// assertEq (CONTRACT.lotMaxNonce(), 10);
// assertEq (CONTRACT.lotRewards(), 0.1 ether);
// + mapping(uint256 => address) lotTicketsMapping;
// + contract balance == 0.1 ether;
//}

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
