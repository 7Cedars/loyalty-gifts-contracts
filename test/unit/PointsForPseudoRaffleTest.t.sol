// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {LoyaltyProgram} from "../mocks/LoyaltyProgram.t.sol";
import {LoyaltyGift} from "../../src/LoyaltyGift.sol";
import {DeployPointsForPseudoRaffle} from "../../script/DeployPointsForPseudoRaffle.s.sol";
import {DeployLoyaltyProgram} from "../../script/DeployLoyaltyProgram.s.sol";
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
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
    event LoyaltyGiftDeployed(address indexed issuer, uint256[] isVoucher);

    uint256 keyZero = vm.envUint("DEFAULT_ANVIL_KEY_0");
    address addressZero = vm.addr(keyZero);
    uint256 keyOne = vm.envUint("DEFAULT_ANVIL_KEY_1");
    address addressOne = vm.addr(keyOne);

    ///////////////////////////////////////////////
    ///                   Setup                 ///
    ///////////////////////////////////////////////

    LoyaltyGift loyaltyGift;
    LoyaltyProgram loyaltyProgram; 

    function setUp() external {
        DeployPointsForPseudoRaffle giftDeployer = new DeployPointsForPseudoRaffle();
        loyaltyGift = giftDeployer.run();

        DeployLoyaltyProgram programDeployer = new DeployLoyaltyProgram();
        (loyaltyProgram, ) = programDeployer.run();
    }

    function testLoyaltyGiftHasGifts() public {
        uint256 numberOfGifts = loyaltyGift.getNumberOfGifts();
        assertNotEq(numberOfGifts, 0);
    }

    function testDeployEmitsevent() public {
        uint256[] memory isVoucher = new uint256[](4); 
        isVoucher[0] = 0; isVoucher[1] = 1; isVoucher[2] = 1; isVoucher[3] = 1;

        vm.expectEmit(true, false, false, false);
        emit LoyaltyGiftDeployed(addressZero, isVoucher);

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

    function testRequirementPassessWithZeroGiftIdAndVouchersMinted() public { 
        uint256[] memory voucherIds = new uint256[](3); 
        voucherIds[0] = 1; voucherIds[1] = 2; voucherIds[2] = 3; 
        uint256[] memory numberOfVouchers = new uint256[](3); 
        numberOfVouchers[0] = 5; numberOfVouchers[1] = 5; numberOfVouchers[2] = 5;
        address programOwner = loyaltyProgram.getOwner(); 

        vm.prank(programOwner); 
        loyaltyProgram.mintLoyaltyVouchers(address(loyaltyGift), voucherIds, numberOfVouchers);

        vm.prank(address(loyaltyProgram));
        bool result = loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 0, 3000);
        assertEq(result, true);
    }

    function testRequirementFailsWithNoVouchers1_2_3Minted() public {
        vm.expectRevert("No vouchers available");   
        vm.prank(address(loyaltyProgram));
        loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 0, 3000);
    }


    function testRequirementRevertsWithInsufficientPoints() public {
        vm.expectRevert("Not enough points");   
        vm.prank(addressZero);
        loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 0, 1000);
    }

    function testRequirementPassessWithSufficientPointsAndVouchers() public {           
        uint256[] memory voucherIds = new uint256[](3); 
        voucherIds[0] = 1; voucherIds[1] = 2; voucherIds[2] = 3; 
        uint256[] memory numberOfVouchers = new uint256[](3); 
        numberOfVouchers[0] = 5; numberOfVouchers[1] = 5; numberOfVouchers[2] = 5;
        address programOwner = loyaltyProgram.getOwner(); 

        vm.prank(programOwner); 
        loyaltyProgram.mintLoyaltyVouchers(address(loyaltyGift), voucherIds, numberOfVouchers);

        vm.prank(address(loyaltyProgram));
        bool result = loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 0, 1250);
        assertEq(result, true);
    }

    ////////////////////////////////////////////
    ///       adjusted balanceOf             ///
    ////////////////////////////////////////////
    function testBalanceOfVoucher0ReturnsSumVouchers1_2_3() public {
        uint256[] memory voucherIds = new uint256[](3); 
        voucherIds[0] = 1; voucherIds[1] = 2; voucherIds[2] = 3; 
        uint256[] memory numberOfVouchers = new uint256[](3); 
        numberOfVouchers[0] = 3; numberOfVouchers[1] = 5; numberOfVouchers[2] = 7;
        address programOwner = loyaltyProgram.getOwner(); 

        vm.prank(programOwner); 
        loyaltyProgram.mintLoyaltyVouchers(address(loyaltyGift), voucherIds, numberOfVouchers);

        console.log("balance voucher 1:", loyaltyGift.balanceOf(programOwner, 1)); 
        console.log("balance voucher 2:", loyaltyGift.balanceOf(programOwner, 2)); 
        console.log("balance voucher 3:", loyaltyGift.balanceOf(programOwner, 3)); 

        assertEq(
            loyaltyGift.balanceOf(programOwner, 0), 
            numberOfVouchers[0] + numberOfVouchers[1] + numberOfVouchers[2] 
            );
    }

    function testMintingVoucher0Reverts() public {
        uint256[] memory voucherIds = new uint256[](1); 
        voucherIds[0] = 0; 
        uint256[] memory numberOfVouchers = new uint256[](1); 
        numberOfVouchers[0] = 25;
        address programOwner = loyaltyProgram.getOwner(); 

        vm.expectRevert(); 
        vm.prank(programOwner); 
        loyaltyProgram.mintLoyaltyVouchers(address(loyaltyGift), voucherIds, numberOfVouchers);
    }


    ///////////////////////////////////////////////
    ///       Random Transferring Voucher       ///
    ///////////////////////////////////////////////

    function testOneVoucherMeansTransferVouchersIsDeterminate() public {
        uint256[] memory giftId = new uint256[](1); 
        giftId[0] = 0; 
        uint256[] memory voucherId = new uint256[](1); 
        voucherId[0] = 2; 
        uint256[] memory numberOfVouchers = new uint256[](1); 
        numberOfVouchers[0] = 25;
        uint256 numberOfTransfers = 10; 
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

        // step 4: calls transfer on gift0 ten times: 
        for (uint256 i; i < numberOfTransfers; i++)
            loyaltyProgram.transferLoyaltyVoucher(
                ownerProgram, 
                loyaltyCardAddress, 
                address(loyaltyGift), 
                0
            ); 
        vm.stopPrank();

        assertEq(loyaltyGift.balanceOf(loyaltyCardAddress, voucherId[0]), numberOfTransfers);
    }

    function testTransferVouchersFallsWithinRange() public {
        uint256[] memory giftId = new uint256[](1); 
        giftId[0] = 0; 
        uint256[] memory voucherIds = new uint256[](3); 
        voucherIds[0] = 1; voucherIds[1] = 2; voucherIds[2] = 3; 
        uint256[] memory numberOfVouchers = new uint256[](3); 
        numberOfVouchers[0] = 5; numberOfVouchers[1] = 25; numberOfVouchers[2] = 50;
        uint256 numberOfTransfers = 40; 
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

        // step 4: calls transfer on gift0 ten times: 
        for (uint256 i; i < numberOfTransfers; i++)
            loyaltyProgram.transferLoyaltyVoucher(
                ownerProgram, 
                loyaltyCardAddress, 
                address(loyaltyGift), 
                0
            ); 
        vm.stopPrank();
        
        assertEq(
            loyaltyGift.balanceOf(loyaltyCardAddress, voucherIds[0]) + 
            loyaltyGift.balanceOf(loyaltyCardAddress, voucherIds[1]) + 
            loyaltyGift.balanceOf(loyaltyCardAddress, voucherIds[2]), 
            numberOfTransfers);
    }


    // all other tests (including for the pseudoRandomNumber function) can be found in fuzz test folder. 



}
