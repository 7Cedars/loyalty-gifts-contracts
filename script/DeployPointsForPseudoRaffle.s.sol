// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {PointsForPseudoRaffle} from "../src/PointsForPseudoRaffle.sol";
import {LoyaltyGift} from "../src/LoyaltyGift.sol";

contract DeployPointsForPseudoRaffle is Script {
    function run() external returns (PointsForPseudoRaffle) {
        vm.startBroadcast();
        PointsForPseudoRaffle pointsForPseudoRaffle = new PointsForPseudoRaffle();
        vm.stopBroadcast();
        return pointsForPseudoRaffle;
    }
}


