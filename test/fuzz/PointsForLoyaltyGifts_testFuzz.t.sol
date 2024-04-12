// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MockLoyaltyProgram} from "../mocks/MockLoyaltyProgram.sol";
import {LoyaltyGift} from "../../src/LoyaltyGift.sol";
import {DeployPointsForLoyaltyGifts} from "../../script/DeployPointsForLoyaltyGifts.s.sol";
import {PointsForLoyaltyGifts} from "../../src/PointsForLoyaltyGifts.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

/**
 * @title Unit tests for LoyaltyGift Contract
 * @author Seven Cedars
 * @notice Tests are intentionally kept very simple.
 */

contract PointsForLoyaltyGifts_testFuzz is Test {
    /**
     * events
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
    event LoyaltyGiftDeployed(address indexed issuer, uint256[] isVoucher);

    uint256 keyZero = vm.envUint("DEFAULT_ANVIL_KEY_0");
    address addressZero = vm.addr(keyZero);
    uint256 keyOne = vm.envUint("DEFAULT_ANVIL_KEY_1");
    address addressOne = vm.addr(keyOne);

    uint256[] NON_VOUCHER_TO_MINT = [0];
    uint256[] AMOUNT_NON_VOUCHER_TO_MINT = [1];

    ///////////////////////////////////////////////
    ///                   Setup                 ///
    ///////////////////////////////////////////////

    LoyaltyGift loyaltyGift;

    function setUp() external {
        DeployPointsForLoyaltyGifts deployer = new DeployPointsForLoyaltyGifts();
        loyaltyGift = deployer.run();
    }

    ///////////////////////////////////////////////
    ///            Issuing gifts                ///
    ///////////////////////////////////////////////
    function testFuzz_GiftZeroReturnsCorrectAssessment(uint256 points) public {
        if (points < 2500) { 
            vm.expectRevert("Not enough points."); 

            vm.prank(addressZero);
            loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 0, points); 
        }

        if (points >= 2500) { 
            vm.prank(addressZero);
            bool result = loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 0, points); 
            
            assertEq(result, true); 
        } 
    }

    function testFuzz_GiftOneReturnsCorrectAssessment(uint256 points) public {
        if (points < 4500) { 
            vm.expectRevert("Not enough points."); 

            vm.prank(addressZero);
            loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 1, points); 
        }

        if (points >= 4500) { 
            vm.prank(addressZero);
            bool result = loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 1, points); 
            
            assertEq(result, true); 
        } 
    }
}
