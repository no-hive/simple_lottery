// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

// https://docs.chain.link/vrf/v2-5/subscription/test-locally#add-the-consumer-contract-to-your-subscription

import {Script} from "forge-std/Script.sol";
import {SimpleLottery} from "../src/lottery.sol";
import "lib/chainlink-evm/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract LotteryScript is Script {
    SimpleLottery public simpleLottery;
    VRFCoordinatorV2_5Mock public vRFCoordinatorV2_5Mock;

    bytes32 KEYHASH =
        0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;

    uint96 _BASEFEE = 100000000000000000;
    uint96 _GASPRICELINK = 1000000000;
    int256 _WEIPERUNITLINK = 3984445400000000;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        vRFCoordinatorV2_5Mock = new VRFCoordinatorV2_5Mock(
            _BASEFEE,
            _GASPRICELINK,
            _WEIPERUNITLINK
        );

        address VRFCoordinatorV2_5Mock_address = address(vRFCoordinatorV2_5Mock);

        simpleLottery = new SimpleLottery(1,VRFCoordinatorV2_5Mock_address,KEYHASH);

        // SimpleLottery_address =

        // VRFCoordinatorV2_5Mock.addConsumer (_subid, SimpleLottery_address);

        vm.stopBroadcast();
    }
}
