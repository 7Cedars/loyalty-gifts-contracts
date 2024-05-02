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
contract PointsForPseudoRaffle_testFuzz is Test {
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

    modifier ownerProgramMintedPointsCardsVouchers() { 
      uint256[] memory giftId = new uint256[](1); 
      giftId[0] = 0; 
      uint256[] memory voucherIds = new uint256[](3); 
      voucherIds[0] = 1; voucherIds[1] = 2; voucherIds[2] = 3; 
      uint256[] memory numberOfVouchers = new uint256[](3); 
      numberOfVouchers[0] = 50; numberOfVouchers[1] = 25; numberOfVouchers[2] = 1;
      address ownerProgram = loyaltyProgram.getOwner(); 

      // step 1: owner mints cards and points. 
      vm.startPrank(ownerProgram);
      loyaltyProgram.mintLoyaltyCards(5); 
      loyaltyProgram.mintLoyaltyPoints(50_000_000); 
      vm.stopPrank();

      // step 2: get address of TBA of card no 1. 
      address loyaltyCardAddress = loyaltyProgram.getTokenBoundAddress(1); 

      // step 3a: owner transfers points to card 1 & transfers card 1 to addressZero 
      vm.startPrank(ownerProgram);
      loyaltyProgram.safeTransferFrom(
          ownerProgram, loyaltyCardAddress, 0, 100_000, ""
      ); 
      loyaltyProgram.safeTransferFrom(
          ownerProgram, addressZero, 1, 1, ""
      );

      // step 3b: owner adds raffle as loyalty gift & mints vouchers
      loyaltyProgram.addLoyaltyGift(address(loyaltyGift), giftId[0]); 
      loyaltyProgram.mintLoyaltyVouchers(address(loyaltyGift), voucherIds, numberOfVouchers);
      vm.stopPrank();

      _; 
    }

    ///////////////////////////////////////////////
    ///                   Setup                 ///
    ///////////////////////////////////////////////

    LoyaltyGift loyaltyGift;
    LoyaltyProgram loyaltyProgram; 

    function setUp() external {
        string memory rpc_url = vm.envString("SELECTED_RPC_URL"); 
        uint256 forkId = vm.createFork(rpc_url);
        vm.selectFork(forkId);

        DeployPointsForPseudoRaffle giftDeployer = new DeployPointsForPseudoRaffle();
        loyaltyGift = giftDeployer.run();

        DeployLoyaltyProgram programDeployer = new DeployLoyaltyProgram();
        (loyaltyProgram, ) = programDeployer.run();
    }

    ///////////////////////////////////////////////
    ///          Requirement fuzz test          ///
    ///////////////////////////////////////////////

    function testFuzz_rafflePseudoRandomlyDistributesGifts(
      uint256 points,
      uint256 timestamp, 
      uint256 blocknumber
      ) public ownerProgramMintedPointsCardsVouchers {
        //setup
        points = bound(points, 0, 25_000); 
        timestamp = bound(timestamp, 1, 2500000000);
        blocknumber = bound(blocknumber, 1, 1500000);
        address loyaltyCardAddress = loyaltyProgram.getTokenBoundAddress(1);
        address ownerProgram = loyaltyProgram.getOwner(); 
        
        // act
        vm.warp(timestamp);
        vm.roll(blocknumber); 

        //checks 
        // check 1: sufficient points. 
        if (points < 1250) { 
          vm.expectRevert("Not enough points"); 

          vm.prank(address(loyaltyProgram));
          loyaltyGift.requirementsLoyaltyGiftMet(loyaltyCardAddress, 0, points); 
        }

        // check 2: no correct token. 
        if (points >= 1250) { 
          vm.prank(address(loyaltyProgram));
          loyaltyProgram.transferLoyaltyVoucher(
                ownerProgram, 
                loyaltyCardAddress, 
                address(loyaltyGift), 
                0
            ); 

          console.log("Gift1:", loyaltyGift.balanceOf(loyaltyCardAddress, 1)); 
          console.log("Gift2:", loyaltyGift.balanceOf(loyaltyCardAddress, 2)); 
          console.log("Gift3:", loyaltyGift.balanceOf(loyaltyCardAddress, 3)); 

          assertEq(
            loyaltyGift.balanceOf(loyaltyCardAddress, 1) + 
            loyaltyGift.balanceOf(loyaltyCardAddress, 2) + 
            loyaltyGift.balanceOf(loyaltyCardAddress, 3), 
            1);
        }
    }
}
