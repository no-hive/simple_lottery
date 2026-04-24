// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

// https://docs.chain.link/vrf/v2-5/subscription/test-locally#add-the-consumer-contract-to-your-subscription

import {Script} from "forge-std/Script.sol";
import {SimpleLottery} from "../src/lottery.sol";
import {VRFCoordinatorV2_5Mock} from "lib/chainlink-evm/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract LotteryScript is Script {
    SimpleLottery public simpleLottery;
    VRFCoordinatorV2_5Mock public vRFCoordinatorV2_5Mock;

    bytes32 immutable KEYHASH =
        0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;

    uint96 immutable _BASEFEE = 100000000000000000;
    uint96 immutable _GASPRICELINK = 1000000000;
    int256 immutable _WEIPERUNITLINK = 3984445400000000;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        vRFCoordinatorV2_5Mock = new VRFCoordinatorV2_5Mock(
            _BASEFEE,
            _GASPRICELINK,
            _WEIPERUNITLINK
        );

        address VRFCoordinatorV2_5Mock_address = address(
            vRFCoordinatorV2_5Mock
        );

        uint256 _subid = vRFCoordinatorV2_5Mock.createSubscription();

        vRFCoordinatorV2_5Mock.fundSubscription(_subid, 100000000000000000000); 

        simpleLottery = new SimpleLottery(
            _subid,
            VRFCoordinatorV2_5Mock_address,
            KEYHASH
        );

        address SimpleLottery_address = address(simpleLottery);

        vRFCoordinatorV2_5Mock.addConsumer(_subid, SimpleLottery_address);

        vm.stopBroadcast();
    }
}
