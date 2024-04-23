// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {LoyaltyProgram} from "../mocks/LoyaltyProgram.t.sol";
import {DateTime} from "../../src/DateTime.sol";
import {LoyaltyGift} from "../../src/LoyaltyGift.sol";
import {DeployFridaysFifteenPercent} from "../../script/DeployFridaysFifteenPercent.s.sol";
import {FridaysFifteenPercent} from "../../src/FridaysFifteenPercent.sol";
import {DeployLoyaltyProgram} from "../../script/DeployLoyaltyProgram.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

/**
 * @title Unit tests for PointsForPseudoRaffle Contract
 * @author Seven Cedars
 * @notice Tests are intentionally kept very simple.
 */


// All this is copy-paste from other tests - still needs clean up and WIL £todo. 
contract FridaysFifteenPercentTest is Test {
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

    LoyaltyGift loyaltyGift;
    LoyaltyProgram loyaltyProgram; 
    address loyaltyCardAddress; 

    ///////////////////////////////////////////////
    ///                   Setup                 ///
    ///////////////////////////////////////////////
    
    modifier programHasCardsPoints() { 
        address ownerProgram = loyaltyProgram.getOwner(); 

        // step 1a: owner mints cards, points. (points are owned by EOA)
        vm.startPrank(ownerProgram);
        loyaltyProgram.mintLoyaltyCards(5); 
        loyaltyProgram.mintLoyaltyPoints(500_000); 
        vm.stopPrank();

        // step 1b: program mints vouchers. (vouchers are owned by loyalty Program contract)
        vm.prank(address(loyaltyProgram)); 

        // step 2: get address of TBA of card no 1. 
        loyaltyCardAddress = loyaltyProgram.getTokenBoundAddress(1); 

        // step 3a: owner transfers points to card 1 & transfers card 1 to addressZero 
        vm.startPrank(ownerProgram);
        loyaltyProgram.safeTransferFrom(
            ownerProgram, loyaltyCardAddress, 0, 10_000, ""
        ); 
        loyaltyProgram.safeTransferFrom(
            ownerProgram, addressZero, 1, 1, ""
        );
        vm.stopPrank(); 

        _; 
    }

    function setUp() external {
        DeployFridaysFifteenPercent giftDeployer = new DeployFridaysFifteenPercent();
        loyaltyGift = giftDeployer.run();

        DeployLoyaltyProgram programDeployer = new DeployLoyaltyProgram();
        (loyaltyProgram, ) = programDeployer.run();
    }

    function testLoyaltyGiftHasGifts() public {
        uint256 numberOfGifts = loyaltyGift.getNumberOfGifts();
        assertNotEq(numberOfGifts, 0);
    }

    function testDeployEmitsevent() public {
      uint256[] memory isVoucher = new uint256[](1);  

      vm.expectEmit(true, false, false, false);
      emit LoyaltyGiftDeployed(addressZero, isVoucher);

      vm.prank(addressZero);
      new FridaysFifteenPercent(); 
    }

    function testGiftCanBeAddedByLoyaltyProgram() public {
      address ownerProgram = loyaltyProgram.getOwner(); 

      vm.prank(ownerProgram);
      loyaltyProgram.addLoyaltyGift(address(loyaltyGift), 0); 
      assertEq(loyaltyProgram.getLoyaltyGiftIsClaimable(address(loyaltyGift), 0), 1); 
    }


    ///////////////////////////////////////////////
    ///             Requirement test            ///
    ///////////////////////////////////////////////

    function testRequirementRevertsWithInsufficientPoints() public { 
      vm.expectRevert("Not enough points"); 

      vm.prank(addressZero); 
      loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 0, 2499); 
    }

    function testRequirementRevertsWithWrongDayOfWeek() public { 
      vm.warp(1712196000); // = Thursday 4 April 2024
      uint256 day = DateTime.getDayOfWeek(block.timestamp); 
      console.logUint(day); 
      vm.expectRevert("It's not Friday!"); 

      vm.prank(addressZero); 
      loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 0, 2500); 
    }

    function testRequirementPassesWithSufficientPointsAndCorrectDayOfWeek() public { 
      vm.warp(1712282400); // = Friday 5 April 2024
      (uint256 year, uint256 month, uint256 day) = DateTime.timestampToDate(block.timestamp); 
      console.logUint(year); 
      console.logUint(month); 
      console.logUint(day); 

      vm.prank(address(loyaltyProgram)); 
      (bool result) = loyaltyGift.requirementsLoyaltyGiftMet(loyaltyCardAddress, 0, 2500);
      assertEq(result, true); 
    }
    
    // all other tests (including for the pseudoRandomNumber function) can be found in fuzz test folder. 

}
