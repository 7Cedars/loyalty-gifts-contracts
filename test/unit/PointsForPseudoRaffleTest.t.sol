// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MockLoyaltyProgram} from "../mocks/MockLoyaltyProgram.sol";
import {LoyaltyGift} from "../../src/LoyaltyGift.sol";
import {DeployPointsForPseudoRaffle} from "../../script/DeployPointsForPseudoRaffle.s.sol";
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

    function setUp() external {
        DeployPointsForPseudoRaffle deployer = new DeployPointsForPseudoRaffle();
        loyaltyGift = deployer.run();
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
        giftId[0] = 1; 
        uint256[] memory numberOfGifts = new uint256[](1); 
        numberOfGifts[0] = 25;

        vm.startPrank(addressZero); 
        loyaltyGift.mintLoyaltyVouchers(giftId, numberOfGifts);
        loyaltyGift.issueLoyaltyVoucher(addressOne, 9999999999999999); // need to fill out uint256 here - but just dummy data
        vm.stopPrank(); 

        assertEq(loyaltyGift.balanceOf(addressOne, 1), 1);
    }

    // function testIssueVouchersFallsWithinRange() public {
        
    // }

    // all other tests (including for the pseudoRandomNumber function) can be found in fuzz test folder. 

}
