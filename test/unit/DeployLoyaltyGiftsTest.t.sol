// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployPointsForLoyaltyGiftsAndVouchers} from "../../script/DeployPointsForLoyaltyGiftsAndVouchers.s.sol";
import {DeployLoyaltyGift} from "../../script/DeployLoyaltyGift.s.sol"; 
import {PointsForLoyaltyGiftsAndVouchers} from "../../src/PointsForLoyaltyGiftsAndVouchers.sol";
import {LoyaltyGift} from "../../src/LoyaltyGift.sol";

contract DeployLoyaltyGiftTest is Test {
    DeployLoyaltyGift public deployer;
    address public vendorOne = makeAddr("vendor1");
    uint256[] VOUCHERS_TO_MINT = [1];
    uint256[] AMOUNT_VOUCHERS_TO_MINT = [24];

    function setUp() public {
        deployer = new DeployLoyaltyGift();
    }

    function testNameDeployedLoyaltyGiftIsCorrect() public {
        LoyaltyGift loyaltyGift = deployer.run();

        string memory expectedUri =
            "https://aqua-famous-sailfish-288.mypinata.cloud/ipfs/QmSshfobzx5jtA14xd7zJ1PtmG8xFaPkAq2DZQagiAkSET/{id}";
        vm.prank(vendorOne);
        loyaltyGift.mintLoyaltyVouchers(VOUCHERS_TO_MINT, AMOUNT_VOUCHERS_TO_MINT);
        string memory actualUri = loyaltyGift.uri(1);
        assert(keccak256(abi.encodePacked(expectedUri)) == keccak256(abi.encodePacked(actualUri)));
    }
}

contract DeployPointsForLoyaltyGiftsAndVouchersTest is Test {
    DeployPointsForLoyaltyGiftsAndVouchers public deployer;
    address public vendorOne = makeAddr("vendor1");
    uint256[] VOUCHERS_TO_MINT = [3];
    uint256[] AMOUNT_VOUCHERS_TO_MINT = [24];

    function setUp() public {
        deployer = new DeployPointsForLoyaltyGiftsAndVouchers();
    }

    function testNameLoyaltyGiftIsCorrect() public {
        PointsForLoyaltyGiftsAndVouchers pointsForLoyaltyGiftsAndVouchers = deployer.run();

        string memory expectedUri =
            "https://aqua-famous-sailfish-288.mypinata.cloud/ipfs/QmSshfobzx5jtA14xd7zJ1PtmG8xFaPkAq2DZQagiAkSET/{id}";
        vm.prank(vendorOne);
        pointsForLoyaltyGiftsAndVouchers.mintLoyaltyVouchers(VOUCHERS_TO_MINT, AMOUNT_VOUCHERS_TO_MINT);
        string memory actualUri = pointsForLoyaltyGiftsAndVouchers.uri(1);
        assert(keccak256(abi.encodePacked(expectedUri)) == keccak256(abi.encodePacked(actualUri)));
    }
}
