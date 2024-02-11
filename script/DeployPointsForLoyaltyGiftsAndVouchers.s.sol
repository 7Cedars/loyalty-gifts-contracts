// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {PointsForLoyaltyGiftsAndVouchers} from "../src/PointsForLoyaltyGiftsAndVouchers.sol";
import {LoyaltyGift} from "../src/LoyaltyGift.sol";

contract DeployPointsForLoyaltyGiftsAndVouchers is Script {
    function run() external returns (PointsForLoyaltyGiftsAndVouchers) {
        vm.startBroadcast();
        PointsForLoyaltyGiftsAndVouchers pointsForLoyaltyGiftsAndVouchers = new PointsForLoyaltyGiftsAndVouchers();
        vm.stopBroadcast();
        return pointsForLoyaltyGiftsAndVouchers;
    }
}


