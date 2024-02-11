// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {PointsForLoyaltyGiftsAndVouchers} from "../src/PointsForLoyaltyGiftsAndVouchers.sol";
import {LoyaltyGift} from "../src/LoyaltyGift.sol";

contract DeployLoyaltyGift is Script {
    // create a config file for this? -- decide later.
    uint256[] public tokenised = [0, 1]; // 0 == false, 1 == true.

    function run() external returns (LoyaltyGift) {
        vm.startBroadcast();
        LoyaltyGift loyaltyGift = new LoyaltyGift(
            "https://aqua-famous-sailfish-288.mypinata.cloud/ipfs/QmSshfobzx5jtA14xd7zJ1PtmG8xFaPkAq2DZQagiAkSET/{id}", 
            tokenised
        );
        vm.stopBroadcast();
        return loyaltyGift;
    }
}