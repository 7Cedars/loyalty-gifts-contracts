// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {LoyaltyProgram} from "../mocks/LoyaltyProgram.t.sol";
import {LoyaltyGift} from "../../src/LoyaltyGift.sol";
import {DeployTieredAccess} from "../../script/DeployTieredAccess.s.sol";
import {TieredAccess} from "../../src/TieredAccess.sol";
import {DeployLoyaltyProgram} from "../../script/DeployLoyaltyProgram.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

/**
 * @title Unit tests for PointsForPseudoRaffle Contract
 * @author Seven Cedars
 * @notice Tests are intentionally kept very simple.
 */

// All this is copy-paste from other tests - still needs clean up and WIL £todo. 
contract TieredAccessTest is Test {
    /**
     * events
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
     event LoyaltyGiftDeployed(address indexed issuer, string indexed version, uint256 indexed numberOfGifts);

    uint256 keyZero = vm.envUint("DEFAULT_ANVIL_KEY_0");
    address addressZero = vm.addr(keyZero);
    uint256 keyOne = vm.envUint("DEFAULT_ANVIL_KEY_1");
    address addressOne = vm.addr(keyOne);

    LoyaltyGift loyaltyGift;
    LoyaltyProgram loyaltyProgram; 

    modifier programHasBronzeSilverGoldTokens() { 
        uint256[] memory tokenIds = new uint256[](3); 
        tokenIds[0] = 0; tokenIds[1] = 1; tokenIds[2] = 2; 
        uint256[] memory numberOfTokens = new uint256[](3); 
        numberOfTokens[0] = 3; numberOfTokens[1] = 3; numberOfTokens[2] = 3; 
        address ownerProgram = loyaltyProgram.getOwner(); 

        // step 1a: owner mints cards, points. (points are owned by EOA)
        vm.startPrank(ownerProgram);
        loyaltyProgram.mintLoyaltyCards(5); 
        loyaltyProgram.mintLoyaltyPoints(500_000); 
        vm.stopPrank();

        // step 1b: program mints vouchers. (vouchers are owned by loyalty Program contract)
        vm.prank(address(loyaltyProgram)); 
        loyaltyGift.mintLoyaltyVouchers(tokenIds, numberOfTokens); 
        
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

    function testLoyaltyGiftHasGifts() public view{
        uint256 numberOfGifts = loyaltyGift.getNumberOfGifts();
        assertNotEq(numberOfGifts, 0);
    }

    function testDeployEmitsevent() public {
        uint256[] memory isVoucher = new uint256[](6); 
        string memory version = "alpha.3";
        isVoucher[0] = 1; isVoucher[1] = 1; isVoucher[2] = 1; 
        isVoucher[3] = 0; isVoucher[4] = 0; isVoucher[5] = 1; 

        vm.expectEmit(true, false, false, false);
        emit LoyaltyGiftDeployed(addressZero, version, isVoucher.length);

        vm.prank(addressZero);
        new TieredAccess(); 
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

    // gift3 // 
    function testGift3revertsWithInsufficientPoints() public { 
        vm.expectRevert("Not enough points"); 

        vm.prank(address(loyaltyProgram)); 
        loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 3, 1499); 
    }

    function testGift3revertsWithoutTokens() public { 
        vm.expectRevert("No Bronze, Silver or Gold token on Card"); 

        vm.prank(address(loyaltyProgram)); 
        loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 3, 1500); 
    }

    function testGift3passesWithBronzeTokenOnLoyaltyCard() public programHasBronzeSilverGoldTokens {  
        address loyaltyCardAddress = loyaltyProgram.getTokenBoundAddress(1);
        address ownerProgram = loyaltyProgram.getOwner();
        console.log("balance owner:", loyaltyProgram.balanceOf(ownerProgram, 0)); 

        vm.prank(ownerProgram); 
        loyaltyProgram.transferLoyaltyVoucher(ownerProgram, loyaltyCardAddress, address(loyaltyGift), 0); 
        loyaltyProgram.checkRequirementsLoyaltyGiftMet(loyaltyCardAddress, address(loyaltyGift), 3); 
        vm.stopPrank(); 
    }
    
    // gift4 // 
     function testGift4revertsWithInsufficientPoints() public { 
        vm.expectRevert("Not enough points"); 

        vm.prank(address(loyaltyProgram));
        loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 4, 2999); 
    }

    function testGift4revertsWithoutSilverOrSilverToken() public programHasBronzeSilverGoldTokens { 
        address loyaltyCardAddress = loyaltyProgram.getTokenBoundAddress(1);
        address ownerProgram = loyaltyProgram.getOwner();

        vm.prank(ownerProgram); 
        loyaltyProgram.transferLoyaltyVoucher(ownerProgram, loyaltyCardAddress, address(loyaltyGift), 0); 

        vm.expectRevert("No Silver or Gold token on Card"); 
        vm.prank(ownerProgram); 
        loyaltyProgram.checkRequirementsLoyaltyGiftMet(loyaltyCardAddress, address(loyaltyGift), 4); 
    }

    function testGift4passesWithSilverTokenOnLoyaltyCard() public programHasBronzeSilverGoldTokens {  
        address loyaltyCardAddress = loyaltyProgram.getTokenBoundAddress(1);
        address ownerProgram = loyaltyProgram.getOwner();

        vm.prank(ownerProgram); 
        loyaltyProgram.transferLoyaltyVoucher(ownerProgram, loyaltyCardAddress, address(loyaltyGift), 1); 

        vm.prank(ownerProgram); 
        (bool result) = loyaltyProgram.checkRequirementsLoyaltyGiftMet(loyaltyCardAddress, address(loyaltyGift), 4); 

        assertEq(result, true); 
    }
    
    // gift5 //
    function testGift5revertsWithInsufficientPoints() public { 
        vm.expectRevert("Not enough points"); 

        vm.prank(address(loyaltyProgram));
        loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 5, 4999); 
    }

    function testGift5revertsWithoutGoldToken() public programHasBronzeSilverGoldTokens { 
        address loyaltyCardAddress = loyaltyProgram.getTokenBoundAddress(1);
        address ownerProgram = loyaltyProgram.getOwner();

        vm.prank(ownerProgram); 
        loyaltyProgram.transferLoyaltyVoucher(ownerProgram, loyaltyCardAddress, address(loyaltyGift), 1); 

        vm.expectRevert("No Gold token on Card"); 
        vm.prank(ownerProgram); 
        loyaltyGift.requirementsLoyaltyGiftMet(loyaltyCardAddress, 5, 5000); 
    }

    function testGift5passesWithGoldTokenOnLoyaltyCard() public programHasBronzeSilverGoldTokens {  
        address loyaltyCardAddress = loyaltyProgram.getTokenBoundAddress(1);
        address ownerProgram = loyaltyProgram.getOwner();

        vm.prank(ownerProgram); 
        loyaltyProgram.transferLoyaltyVoucher(ownerProgram, loyaltyCardAddress, address(loyaltyGift), 2); 

        vm.prank(ownerProgram); 
        (bool result) = loyaltyProgram.checkRequirementsLoyaltyGiftMet(loyaltyCardAddress, address(loyaltyGift), 5); 

        assertEq(result, true); 
    }

    // all other tests (including for the pseudoRandomNumber function) can be found in fuzz test folder. 

}
