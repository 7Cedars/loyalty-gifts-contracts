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
    LoyaltyProgram loyaltyProgram; 
    address loyaltyCardAddress; 
    address ownerProgram; 

    modifier programHasCardsPoints() { 
        ownerProgram = loyaltyProgram.getOwner(); 

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
        string memory rpc_url = vm.envString("SELECTED_RPC_URL"); 
        uint256 forkId = vm.createFork(rpc_url);
        vm.selectFork(forkId);

        DeployFridaysFifteenPercent giftDeployer = new DeployFridaysFifteenPercent();
        loyaltyGift = giftDeployer.run();

        DeployLoyaltyProgram programDeployer = new DeployLoyaltyProgram();
        (loyaltyProgram, ) = programDeployer.run();
    }

    ///////////////////////////////////////////////
    ///          Requirement fuzz test          ///
    ///////////////////////////////////////////////

    function testFuzz_requirementReturnsCorrectTimedAssessment(
      uint256 points,
      uint256 timestamp
      ) public programHasCardsPoints {
        //setup
        points = bound(points, 0, 25_000); 
        timestamp = bound(timestamp, 1, 2500000000);
        uint256 dayOfWeek = DateTime.getDayOfWeek(timestamp); 
        console.logUint(dayOfWeek);
        
        // act
        vm.warp(timestamp);
        

        // act & checks 

        // check 2: sufficient points but incorrect date. 
        if (points >= 2500 && dayOfWeek != 5) { 
          vm.expectRevert("It's not Friday!"); 

          vm.prank(addressZero);
          loyaltyProgram.checkRequirementsLoyaltyGiftMet(loyaltyCardAddress, address(loyaltyGift), 0); 
        }

        // check 3: requirement passes with sufficient points & correct date. 
        if (points >= 2500 && dayOfWeek == 5) { 
          vm.prank(addressZero);
          bool result = loyaltyProgram.checkRequirementsLoyaltyGiftMet(loyaltyCardAddress, address(loyaltyGift), 0); 

          assertEq(result, true);
        }
    }
}
