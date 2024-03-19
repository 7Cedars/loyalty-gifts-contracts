// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {PointsForLoyaltyVouchers} from "../src/PointsForLoyaltyVouchers.sol";
import {LoyaltyGift} from "../src/LoyaltyGift.sol";

contract DeployPointsForLoyaltyVouchers is Script {
    function run() external returns (PointsForLoyaltyVouchers) {
        vm.startBroadcast();
        PointsForLoyaltyVouchers pointsForLoyaltyVouchers = new PointsForLoyaltyVouchers();
        vm.stopBroadcast();
        return pointsForLoyaltyVouchers;
    }
}


