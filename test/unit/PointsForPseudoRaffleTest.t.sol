// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MockLoyaltyProgram} from "../mocks/MockLoyaltyProgram.sol";
import {LoyaltyGift} from "../../src/LoyaltyGift.sol";
import {DeployPointsForPseudoRaffle} from "../../script/DeployPointsForPseudoRaffle.s.sol";
import {DeployMockLoyaltyProgram} from "../../script/DeployMockLoyaltyProgram.s.sol";
import {PointsForPseudoRaffle} from "../../src/PointsForPseudoRaffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

/**
 * @title Unit tests for PointsForPseudoRaffle Contract
 * @author Seven Cedars
 * @notice Tests are intentionally kept very simple.
 */


// All this is copy-paste from other tests - still needs clean up and WIL £todo. 
contract PointsForPseudoRaffleTest is Test {
    /**
     * events
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(
        address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values
    );
    event LoyaltyGiftDeployed(address indexed issuer);

    uint256 keyZero = vm.envUint("DEFAULT_ANVIL_KEY_0");
    address addressZero = vm.addr(keyZero);
    uint256 keyOne = vm.envUint("DEFAULT_ANVIL_KEY_1");
    address addressOne = vm.addr(keyOne);

    ///////////////////////////////////////////////
    ///                   Setup                 ///
    ///////////////////////////////////////////////

    LoyaltyGift loyaltyGift;
    MockLoyaltyProgram loyaltyProgram; 

    function setUp() external {
        DeployPointsForPseudoRaffle giftDeployer = new DeployPointsForPseudoRaffle();
        loyaltyGift = giftDeployer.run();

        DeployMockLoyaltyProgram programDeployer = new DeployMockLoyaltyProgram();
        (loyaltyProgram, ) = programDeployer.run();
    }

    function testLoyaltyGiftHasGifts() public {
        uint256 numberOfGifts = loyaltyGift.getNumberOfGifts();
        assertNotEq(numberOfGifts, 0);
    }

    function testDeployEmitsevent() public {
        vm.expectEmit(true, false, false, false);
        emit LoyaltyGiftDeployed(addressZero);

        vm.prank(addressZero);
        new PointsForPseudoRaffle(); 
    }

    ///////////////////////////////////////////////
    ///             Requirement test            ///
    ///////////////////////////////////////////////
    
    function testRequirementRevertsWithNonZeroGiftId() public {
        vm.expectRevert("Invalid token");     
        vm.prank(addressZero);
        loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 1, 3000);

        vm.expectRevert("Invalid token");     
        vm.prank(addressZero);
        loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 2, 3000);
    }

    function testRequirementPassessWithZeroGiftId() public {   
        vm.prank(addressZero);
        bool result = loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 0, 3000);
        assertEq(result, true);
    }

    function testRequirementRevertsWithInsufficientPoints() public {
        vm.expectRevert("Not enough points");   
        vm.prank(addressZero);
        loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 0, 1000);
    }

    function testRequirementPassessWithSufficientPoints() public {   
        vm.prank(addressZero);
        bool result = loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 0, 1250);
        assertEq(result, true);
    }

    ///////////////////////////////////////////////
    ///         Random Issuing Voucher          ///
    ///////////////////////////////////////////////
    function testNoVoucherMeansIssueVouchersReverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                LoyaltyGift.LoyaltyGift__NoVouchersAvailable.selector, address(loyaltyGift)
            )
        );  
        vm.prank(addressZero);
        loyaltyGift.issueLoyaltyVoucher(addressOne, 1); 
    }

    function testOneVoucherMeansIssueVouchersIsDeterminate() public {
        uint256[] memory giftId = new uint256[](1); 
        giftId[0] = 0; 
        uint256[] memory voucherId = new uint256[](1); 
        voucherId[0] = 2; 
        uint256[] memory numberOfVouchers = new uint256[](1); 
        numberOfVouchers[0] = 25;
        address ownerProgram = loyaltyProgram.getOwner(); 

        // step 1: owner mints cards and points. 
        vm.startPrank(ownerProgram);
        loyaltyProgram.mintLoyaltyCards(5); 
        loyaltyProgram.mintLoyaltyPoints(50_000); 
        vm.stopPrank();

        // step 2: get address of TBA of card no 1. 
        address loyaltyCardAddress = loyaltyProgram.getTokenBoundAddress(1); 

        // step 3a: owner transfers points to card 1 & transfers card 1 to addressZero 
        vm.startPrank(ownerProgram);
        loyaltyProgram.safeTransferFrom(
            ownerProgram, loyaltyCardAddress, 0, 10_000, ""
        ); 
        loyaltyProgram.safeTransferFrom(
            ownerProgram, addressZero, 1, 1, ""
        );

        // step 3b: owner adds raffle as loyalty gift & mints vouchers
        loyaltyProgram.addLoyaltyGift(address(loyaltyGift), giftId[0]); 
        loyaltyProgram.mintLoyaltyVouchers(address(loyaltyGift), voucherId, numberOfVouchers);
        vm.stopPrank();

        // step 4: loyaltyProgram calls raffle giftId 0 -> the available vouchers should be issued  . 
        vm.prank(address(loyaltyProgram));
        loyaltyGift.issueLoyaltyVoucher(loyaltyCardAddress, giftId[0]); 
        
        assertEq(loyaltyGift.balanceOf(loyaltyCardAddress, voucherId[0]), 1);
    }

    function testIssueVouchersFallsWithinRange() public {
        uint256[] memory giftId = new uint256[](1); 
        giftId[0] = 0; 
        uint256[] memory voucherIds = new uint256[](3); 
        voucherIds[0] = 1; voucherIds[1] = 2; voucherIds[2] = 3; 
        uint256[] memory numberOfVouchers = new uint256[](3); 
        numberOfVouchers[0] = 5; numberOfVouchers[1] = 25; numberOfVouchers[2] = 50;
        address ownerProgram = loyaltyProgram.getOwner(); 

        // step 1: owner mints cards and points. 
        vm.startPrank(ownerProgram);
        loyaltyProgram.mintLoyaltyCards(5); 
        loyaltyProgram.mintLoyaltyPoints(50_000); 
        vm.stopPrank();

        // step 2: get address of TBA of card no 1. 
        address loyaltyCardAddress = loyaltyProgram.getTokenBoundAddress(1); 

        // step 3a: owner transfers points to card 1 & transfers card 1 to addressZero 
        vm.startPrank(ownerProgram);
        loyaltyProgram.safeTransferFrom(
            ownerProgram, loyaltyCardAddress, 0, 10_000, ""
        ); 
        loyaltyProgram.safeTransferFrom(
            ownerProgram, addressZero, 1, 1, ""
        );

        // step 3b: owner adds raffle as loyalty gift & mints vouchers
        loyaltyProgram.addLoyaltyGift(address(loyaltyGift), giftId[0]); 
        loyaltyProgram.mintLoyaltyVouchers(address(loyaltyGift), voucherIds, numberOfVouchers);
        vm.stopPrank();

        // step 4: loyaltyProgram calls raffle giftId 0 -> the available vouchers should be issued  . 
        vm.prank(address(loyaltyProgram));
        loyaltyGift.issueLoyaltyVoucher(loyaltyCardAddress, giftId[0]); 
        
        assertEq(
            loyaltyGift.balanceOf(loyaltyCardAddress, voucherIds[0]) + 
            loyaltyGift.balanceOf(loyaltyCardAddress, voucherIds[1]) + 
            loyaltyGift.balanceOf(loyaltyCardAddress, voucherIds[2]), 
            1);
    }
    // all other tests (including for the pseudoRandomNumber function) can be found in fuzz test folder. 

}
