// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {LoyaltyProgram} from "../mocks/LoyaltyProgram.t.sol";
import {LoyaltyGift} from "../../src/LoyaltyGift.sol";
import {DeployPointsForLoyaltyGifts} from "../../script/DeployPointsForLoyaltyGifts.s.sol";
import {DeployLoyaltyProgram} from "../../script/DeployLoyaltyProgram.s.sol";
import {PointsForLoyaltyGifts} from "../../src/PointsForLoyaltyGifts.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

/**
 * @title Unit tests for LoyaltyGift Contract
 * @author Seven Cedars
 * @notice Tests are intentionally kept very simple.
 */

contract PointsForLoyaltyGiftsTest is Test {
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

    ///////////////////////////////////////////////
    ///                   Setup                 ///
    ///////////////////////////////////////////////


    function setUp() external {
        DeployPointsForLoyaltyGifts deployer = new DeployPointsForLoyaltyGifts();
        loyaltyGift = deployer.run();

        DeployLoyaltyProgram programDeployer = new DeployLoyaltyProgram();
        (loyaltyProgram, ) = programDeployer.run();
    }

    function testLoyaltyGiftHasGifts() public {
        uint256 numberOfGifts = loyaltyGift.getNumberOfGifts();
        assertNotEq(numberOfGifts, 0);
    }

    function testDeployEmitsevent() public {
        uint256[] memory isVoucher = new uint256[](2); 

        vm.expectEmit(true, false, false, false);
        emit LoyaltyGiftDeployed(addressZero, isVoucher);
        
        vm.prank(addressZero);
        new PointsForLoyaltyGifts();
    }

    function testGiftCanBeAddedByLoyaltyProgram() public {
      address ownerProgram = loyaltyProgram.getOwner(); 

      vm.prank(ownerProgram);
      loyaltyProgram.addLoyaltyGift(address(loyaltyGift), 0); 
      assertEq(loyaltyProgram.getLoyaltyGiftIsClaimable(address(loyaltyGift), 0), 1); 
    }

    ///////////////////////////////////////////////
    ///     test RequiremntMet                  ///
    ///////////////////////////////////////////////



    
}
