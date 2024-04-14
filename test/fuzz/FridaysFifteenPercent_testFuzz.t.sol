// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MockLoyaltyProgram} from "../mocks/MockLoyaltyProgram.t.sol";
import {DateTime} from "../../src/DateTime.sol";
import {LoyaltyGift} from "../../src/LoyaltyGift.sol";
import {DeployFridaysFifteenPercent} from "../../script/DeployFridaysFifteenPercent.s.sol";
import {FridaysFifteenPercent} from "../../src/FridaysFifteenPercent.sol";
import {DeployMockLoyaltyProgram} from "../../script/DeployMockLoyaltyProgram.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

/**
 * @title Unit tests for FridaysFifteenPercent Contract
 * @author Seven Cedars
 * @notice Tests are intentionally kept very simple.
 */

// All this is copy-paste from other tests - still needs clean up and WIL £todo. 
contract FridaysFifteenPercent_testFuzz is Test {
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
    MockLoyaltyProgram loyaltyProgram; 

    function setUp() external {
        DeployFridaysFifteenPercent giftDeployer = new DeployFridaysFifteenPercent();
        loyaltyGift = giftDeployer.run();

        DeployMockLoyaltyProgram programDeployer = new DeployMockLoyaltyProgram();
        (loyaltyProgram, ) = programDeployer.run();
    }

    ///////////////////////////////////////////////
    ///          Requirement fuzz test          ///
    ///////////////////////////////////////////////

    function testFuzz_requirementReturnsCorrectTimedAssessment(
      uint256 points,
      uint256 timestamp
      ) public  {
        //setup
        points = bound(points, 0, 25_000); 
        timestamp = bound(timestamp, 1, 2500000000);
        uint256 dayOfWeek = DateTime.getDayOfWeek(timestamp); 
        console.logUint(dayOfWeek);
        
        // act
        vm.warp(timestamp);

        // act & checks 
        // check 1: sufficient points. 
        if (points < 2500) { 
          vm.expectRevert("Not enough points"); 

          vm.prank(addressZero);
          loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 0, points); 
        }

        // check 2: sufficient points but incorrect date. 
        if (points >= 2500 && dayOfWeek != 5) { 
          vm.expectRevert("It's not Friday!"); 

          vm.prank(addressZero);
          loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 0, points); 
        }

        // check 3: requirement passes with sufficient points & correct date. 
        if (points >= 2500 && dayOfWeek == 5) { 
          vm.prank(addressZero);
          bool result = loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 0, points);

          assertEq(result, true);
        }
    }
}
