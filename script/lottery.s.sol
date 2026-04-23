// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {SimpleLottery} from "../src/lottery.sol";

contract LotteryScript is Script {
    SimpleLottery public siSmpleLottery;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        siSmpleLottery = new SimpleLottery();

        vm.stopBroadcast();
    }
}
