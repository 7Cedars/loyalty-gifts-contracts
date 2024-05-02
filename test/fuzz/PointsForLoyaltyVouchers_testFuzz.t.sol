// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {LoyaltyProgram} from "../mocks/LoyaltyProgram.t.sol";
import {LoyaltyGift} from "../../src/LoyaltyGift.sol";
import {DeployPointsForLoyaltyVouchers} from "../../script/DeployPointsForLoyaltyVouchers.s.sol";
import {DeployLoyaltyProgram} from "../../script/DeployLoyaltyProgram.s.sol";
import {PointsForLoyaltyVouchers} from "../../src/PointsForLoyaltyVouchers.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

/**
 * @title Unit tests for LoyaltyGift Contract
 * @author Seven Cedars
 * @notice Tests are intentionally kept very simple.
 * Fuzziness is introduced in integration tests.
 */

contract PointsForLoyaltyVouchers_testFuzz is Test {
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

    // can I take these out? £check
    uint256[] VOUCHERS_TO_MINT = [1];
    uint256[] AMOUNT_VOUCHERS_TO_MINT = [24];
    uint256[] NON_TOKENISED_TO_MINT = [0];
    uint256[] AMOUNT_NON_TOKENISED_TO_MINT = [1];

    ///////////////////////////////////////////////
    ///                   Setup                 ///
    ///////////////////////////////////////////////

    LoyaltyGift loyaltyGift;
    LoyaltyProgram loyaltyProgram;
    address ownerProgram;  
    address loyaltyCardAddress; 

    modifier programHasCardsPoints() { 
        ownerProgram = loyaltyProgram.getOwner(); 

        // step 1a: owner mints cards, points. (points are owned by EOA)
        vm.startPrank(ownerProgram);
        loyaltyProgram.mintLoyaltyCards(5); 
        loyaltyProgram.mintLoyaltyPoints(100_000); 
        vm.stopPrank();

        // step 1b: program mints vouchers. (vouchers are owned by loyalty Program contract)
        vm.prank(address(loyaltyProgram)); 

        // step 2: get address of TBA of card no 1. 
        loyaltyCardAddress = loyaltyProgram.getTokenBoundAddress(1); 

        // step 3a: owner transfers card 1 to addressZero 
        vm.startPrank(ownerProgram);
        loyaltyProgram.safeTransferFrom(
            ownerProgram, addressZero, 1, 1, ""
        );
        vm.stopPrank(); 

        _; 
    }

    function setUp() external {
        string memory rpc_url = vm.envString("SELECTED_RPC_URL"); 
        uint256 forkId = vm.createFork(rpc_url);
        vm.selectFork(forkId);

        DeployPointsForLoyaltyVouchers deployer = new DeployPointsForLoyaltyVouchers();
        loyaltyGift = deployer.run();

        DeployLoyaltyProgram programDeployer = new DeployLoyaltyProgram();
        (loyaltyProgram, ) = programDeployer.run();

    }

    ///////////////////////////////////////////////
    ///            Issuing gifts                ///
    ///////////////////////////////////////////////
    function testFuzz_GiftZeroReturnsCorrectAssessment(uint256 points) public programHasCardsPoints {
        points = bound(points, 1, 100_000); 
        vm.prank(ownerProgram);
        loyaltyProgram.safeTransferFrom(ownerProgram, loyaltyCardAddress, 0, points, ""); 

        if (points < 2500) { 
            vm.expectRevert("Not enough points."); 

            vm.prank(addressZero);
            loyaltyProgram.checkRequirementsLoyaltyGiftMet(loyaltyCardAddress, address(loyaltyGift), 0); 
        }

        if (points >= 2500) { 
            vm.prank(addressZero);
            bool result = loyaltyProgram.checkRequirementsLoyaltyGiftMet(loyaltyCardAddress, address(loyaltyGift), 0); 
            
            assertEq(result, true); 
        } 
    }

    function testFuzz_GiftOneReturnsCorrectAssessment(uint256 points) public programHasCardsPoints {
        points = bound(points, 1, 100_000); 
        vm.prank(ownerProgram);
        loyaltyProgram.safeTransferFrom(ownerProgram, loyaltyCardAddress, 0, points, ""); 

        if (points < 4500) { 
            vm.expectRevert("Not enough points."); 

            vm.prank(addressZero);
            loyaltyProgram.checkRequirementsLoyaltyGiftMet(loyaltyCardAddress, address(loyaltyGift), 1); 
        }

        if (points >= 4500) { 
            vm.prank(addressZero);
            bool result = loyaltyProgram.checkRequirementsLoyaltyGiftMet(loyaltyCardAddress, address(loyaltyGift), 1); 
            
            assertEq(result, true); 
        } 
    }

    function testFuzz_GiftTwoReturnsCorrectAssessment(uint256 points) public programHasCardsPoints {
        points = bound(points, 1, 100_000); 
        vm.prank(ownerProgram);
        loyaltyProgram.safeTransferFrom(ownerProgram, loyaltyCardAddress, 0, points, ""); 

        if (points < 50_000) { 
            vm.expectRevert("Not enough points."); 

            vm.prank(addressZero);
            loyaltyProgram.checkRequirementsLoyaltyGiftMet(loyaltyCardAddress, address(loyaltyGift), 2); 
        }

        if (points >= 50_000) { 
            vm.prank(addressZero);
            bool result = loyaltyProgram.checkRequirementsLoyaltyGiftMet(loyaltyCardAddress, address(loyaltyGift), 2); 
            
            assertEq(result, true); 
        } 
    }

}
