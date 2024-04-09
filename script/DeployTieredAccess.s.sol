// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {TieredAccess} from "../src/TieredAccess.sol";
import {LoyaltyGift} from "../src/LoyaltyGift.sol";

contract DeployTieredAccess is Script {
    function run() external returns (TieredAccess) {
        vm.startBroadcast();
        TieredAccess tieredAccess = new TieredAccess();
        vm.stopBroadcast();
        return tieredAccess;
    }
}


