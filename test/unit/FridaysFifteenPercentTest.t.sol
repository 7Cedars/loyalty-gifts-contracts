// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MockLoyaltyProgram} from "../mocks/MockLoyaltyProgram.sol";
import {DateTime} from "../../src/DateTime.sol";
import {LoyaltyGift} from "../../src/LoyaltyGift.sol";
import {DeployFridaysFifteenPercent} from "../../script/DeployFridaysFifteenPercent.s.sol";
import {FridaysFifteenPercent} from "../../src/FridaysFifteenPercent.sol";
import {DeployMockLoyaltyProgram} from "../../script/DeployMockLoyaltyProgram.s.sol";
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
    MockLoyaltyProgram loyaltyProgram; 

    ///////////////////////////////////////////////
    ///                   Setup                 ///
    ///////////////////////////////////////////////

    function setUp() external {
        DeployFridaysFifteenPercent giftDeployer = new DeployFridaysFifteenPercent();
        loyaltyGift = giftDeployer.run();

        DeployMockLoyaltyProgram programDeployer = new DeployMockLoyaltyProgram();
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

      vm.prank(addressZero); 
      (bool result) = loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 0, 2500); 
      assertEq(result, true); 
    }
    
    // all other tests (including for the pseudoRandomNumber function) can be found in fuzz test folder. 

}
