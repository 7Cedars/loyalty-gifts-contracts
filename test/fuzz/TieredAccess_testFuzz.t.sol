// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {LoyaltyProgram} from "../mocks/LoyaltyProgram.t.sol";
import {LoyaltyGift} from "../../src/LoyaltyGift.sol";
import {DeployTieredAccess} from "../../script/DeployTieredAccess.s.sol";
import {TieredAccess} from "../../src/TieredAccess.sol";
import {DeployLoyaltyProgram} from "../../script/DeployLoyaltyProgram.s.sol";

/**
 * @title Unit tests for LoyaltyGift Contract
 * @author Seven Cedars
 * @notice Tests are intentionally kept very simple.
 * Fuzziness is introduced in integration tests.
 */

contract TieredAccess_testFuzz is Test {
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

    LoyaltyGift loyaltyGift;
    LoyaltyProgram loyaltyProgram; 

    modifier programHasBronzeSilverGoldTokens() { 
      uint256[] memory voucherIds = new uint256[](3); 
      voucherIds[0] = 0; voucherIds[1] = 1; voucherIds[2] = 2; 
      uint256[] memory numberOfVouchers = new uint256[](3); 
      numberOfVouchers[0] = 3; numberOfVouchers[1] = 3; numberOfVouchers[2] = 3; 
      address ownerProgram = loyaltyProgram.getOwner(); 

      // step 1a: owner mints cards, points. (points are owned by EOA)
      vm.startPrank(ownerProgram);
      loyaltyProgram.mintLoyaltyCards(5); 
      loyaltyProgram.mintLoyaltyPoints(250_000_000); 
      loyaltyProgram.mintLoyaltyVouchers(address(loyaltyGift), voucherIds, numberOfVouchers); 
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
      vm.stopPrank(); 

      _; 
    }

    ///////////////////////////////////////////////
    ///                   Setup                 ///
    ///////////////////////////////////////////////

    function setUp() external {
        string memory rpc_url = vm.envString("SELECTED_RPC_URL"); 
        uint256 forkId = vm.createFork(rpc_url);
        vm.selectFork(forkId);

        DeployTieredAccess giftDeployer = new DeployTieredAccess();
        loyaltyGift = giftDeployer.run();

        DeployLoyaltyProgram programDeployer = new DeployLoyaltyProgram();
        (loyaltyProgram, ) = programDeployer.run();
    }

    ///////////////////////////////////////////////
    ///        Requirement fuzz test            ///
    ///////////////////////////////////////////////

    // gift3 // 
    function testFuzz_Gift3ReturnsCorrectAssessment(
      uint256 points, 
      uint256 tokenId
      ) public programHasBronzeSilverGoldTokens {
        //setup
        points = bound(points, 0, 100_000); 
        tokenId = bound(tokenId, 0, 3); 
        address loyaltyCardAddress = loyaltyProgram.getTokenBoundAddress(1);
        address ownerProgram = loyaltyProgram.getOwner(); 

        // act
        // if tokenId = 3, no token will be transferred at all. 
        // if tokenId != 3, selected token will be transferred. 
        if (tokenId != 3) {
          vm.prank(ownerProgram); 
          loyaltyProgram.transferLoyaltyVoucher(
            ownerProgram, 
            loyaltyCardAddress, 
            address(loyaltyGift),
            tokenId
          ); 
        }
        
        //checks 
        // check 1: sufficient points. 
        if (points < 1500) { 
          vm.expectRevert("Not enough points"); 

          vm.prank(address(loyaltyProgram));
          loyaltyGift.requirementsLoyaltyGiftMet(loyaltyCardAddress, 3, points); 
        }

        // check 2: no correct token. 
        if (points >= 1500 && tokenId == 3) { 
          vm.expectRevert("No Bronze, Silver or Gold token on Card"); 

          vm.prank(address(loyaltyProgram));
          loyaltyGift.requirementsLoyaltyGiftMet(loyaltyCardAddress, 3, points); 
        }

        // check 3: pass requirement test 
        if (points >= 1500 && tokenId != 3) {
          vm.prank(address(loyaltyProgram)); 
          (bool result) = loyaltyGift.requirementsLoyaltyGiftMet(loyaltyCardAddress, 3, points); 

          assertEq(result, true); 
        }
    }

    // gift4 // 
    function testFuzz_Gift4ReturnsCorrectAssessment(
      uint256 points, 
      uint256 tokenId
      ) public programHasBronzeSilverGoldTokens {
        //setup
        points = bound(points, 0, 100_000); 
        tokenId = bound(tokenId, 0, 3); 
        address loyaltyCardAddress = loyaltyProgram.getTokenBoundAddress(1);
        address ownerProgram = loyaltyProgram.getOwner(); 

        // act
        // if tokenId = 3, no (bronze, silver or gold) token will be transferred. 
        if (tokenId != 3) {
          vm.prank(ownerProgram); 
          loyaltyProgram.transferLoyaltyVoucher(
            ownerProgram, 
            loyaltyCardAddress, 
            address(loyaltyGift), 
            tokenId
          ); 
        }
        
        //checks 
        // check 1: sufficient points. 
        if (points < 3000) { 
          vm.expectRevert("Not enough points"); 

          vm.prank(address(loyaltyProgram));
          loyaltyGift.requirementsLoyaltyGiftMet(loyaltyCardAddress, 4, points); 
        }

        // check 2: no correct token. 
        if (points >= 3000 && (tokenId == 0 || tokenId == 3)) { 
          vm.expectRevert("No Silver or Gold token on Card"); 

          vm.prank(address(loyaltyProgram));
          loyaltyGift.requirementsLoyaltyGiftMet(loyaltyCardAddress, 4, points); 
        }

        // check 3: pass requirement test 
        if (points >= 3000 && (tokenId == 1 || tokenId == 2)) {
          vm.prank(address(loyaltyProgram)); 
          (bool result) = loyaltyGift.requirementsLoyaltyGiftMet(loyaltyCardAddress, 4, points); 

          assertEq(result, true); 
        }
    }

     // gift5 // 
    function testFuzz_Gift5ReturnsCorrectAssessment(
      uint256 points, 
      uint256 tokenId
      ) public programHasBronzeSilverGoldTokens {
        //setup
        points = bound(points, 0, 100_000); 
        tokenId = bound(tokenId, 0, 3); 
        address loyaltyCardAddress = loyaltyProgram.getTokenBoundAddress(1);
        address ownerProgram = loyaltyProgram.getOwner(); 

        // act
        // if tokenId = 3, no (bronze, silver or gold) token will be transferred. 
         if (tokenId != 3) {
          vm.prank(ownerProgram); 
          loyaltyProgram.transferLoyaltyVoucher(
            ownerProgram, 
            loyaltyCardAddress, 
            address(loyaltyGift), 
            tokenId
          ); 
        }
        
        //checks 
        // check 1: sufficient points. 
        if (points < 5000) { 
          vm.expectRevert("Not enough points"); 

          vm.prank(address(loyaltyProgram));
          loyaltyGift.requirementsLoyaltyGiftMet(loyaltyCardAddress, 5, points); 
        }

        // check 2: no correct token. 
        if (points >= 5000 && tokenId != 2) { 
          vm.expectRevert("No Gold token on Card"); 

          vm.prank(address(loyaltyProgram));
          loyaltyGift.requirementsLoyaltyGiftMet(loyaltyCardAddress, 5, points); 
        }

        // check 3: pass requirement test 
        if (points >= 5000 && tokenId == 2) {
          vm.prank(address(loyaltyProgram)); 
          (bool result) = loyaltyGift.requirementsLoyaltyGiftMet(loyaltyCardAddress, 5, points); 

          assertEq(result, true); 
        }
    }
}
