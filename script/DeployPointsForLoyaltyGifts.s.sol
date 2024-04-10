// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {PointsForLoyaltyGifts} from "../src/PointsForLoyaltyGifts.sol";
import {LoyaltyGift} from "../src/LoyaltyGift.sol";

contract DeployPointsForLoyaltyGifts is Script {
    function run() external returns (PointsForLoyaltyGifts) {
        vm.startBroadcast();
        PointsForLoyaltyGifts pointsForLoyaltyGifts = new PointsForLoyaltyGifts();
        vm.stopBroadcast();
        return pointsForLoyaltyGifts;
    }
}


