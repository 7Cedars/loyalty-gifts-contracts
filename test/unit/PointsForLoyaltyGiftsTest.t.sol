// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MockLoyaltyProgram} from "../mocks/MockLoyaltyProgram.sol";
import {LoyaltyGift} from "../../src/LoyaltyGift.sol";
import {DeployPointsForLoyaltyGifts} from "../../script/DeployPointsForLoyaltyGifts.s.sol";
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
        DeployPointsForLoyaltyGifts deployer = new DeployPointsForLoyaltyGifts();
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
        new PointsForLoyaltyGifts();
    }

    ///////////////////////////////////////////////
    ///            Issuing gifts                ///
    ///////////////////////////////////////////////
    function testReturnsTrueForSuccess() public {
        vm.prank(addressZero);
        bool result = loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 0, 3000); 
        assertEq(result, true);
    }

    ///////////////////////////////////////////////
    ///    Reclaiming Tokens (vouchers)         ///
    ///////////////////////////////////////////////
    function testRedeemRevertsForNonAvailableTokenisedGift() public {
        uint256 nonVoucherId = 0; 

        vm.expectRevert(
            abi.encodeWithSelector(
                LoyaltyGift.LoyaltyGift__IsNotVoucher.selector, address(loyaltyGift), nonVoucherId
            )
        );
        vm.prank(addressZero);
        loyaltyGift.redeemLoyaltyVoucher(address(0), nonVoucherId);
    }

}
