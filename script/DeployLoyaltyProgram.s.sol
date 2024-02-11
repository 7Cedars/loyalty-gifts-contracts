// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MockLoyaltyProgram} from "../test/mocks/MockLoyaltyProgram.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {PointsForLoyaltyGiftsAndVouchers} from "../src/PointsForLoyaltyGiftsAndVouchers.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract DeployLoyaltyProgram is Script {
    MockLoyaltyProgram loyaltyProgram;

    // NB: If I need a helper config, see helperConfig.s.sol + learning/foundry-fund-me-f23
    function run() external returns (MockLoyaltyProgram, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        string memory name = "Loyalty Program"; 
        string memory version = "1";

        (, string memory uri,,, address erc65511Registry, address erc65511Implementation,) =
            helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        loyaltyProgram = new MockLoyaltyProgram(
        uri, 
        name,
        version,
        erc65511Registry,
        payable(erc65511Implementation)
        );
        vm.stopBroadcast();

        return (loyaltyProgram, helperConfig);
    }
}
