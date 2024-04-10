// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Script} from "forge-std/Script.sol";
import {FridaysFifteenPercent} from "../src/FridaysFifteenPercent.sol";
import {LoyaltyGift} from "../src/LoyaltyGift.sol";

contract DeployFridaysFifteenPercent is Script {
    function run() external returns (FridaysFifteenPercent) {
        vm.startBroadcast();
        FridaysFifteenPercent fridaysFifteenPercent = new FridaysFifteenPercent();
        vm.stopBroadcast();
        return fridaysFifteenPercent;
    }
}


