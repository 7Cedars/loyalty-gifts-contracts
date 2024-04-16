// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {LoyaltyProgram} from "../mocks/LoyaltyProgram.t.sol";
import {LoyaltyGift} from "../../src/LoyaltyGift.sol";
import {DeployPointsForLoyaltyVouchers} from "../../script/DeployPointsForLoyaltyVouchers.s.sol";
import {PointsForLoyaltyVouchers} from "../../src/PointsForLoyaltyVouchers.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

/**
 * @title Unit tests for LoyaltyGift Contract
 * @author Seven Cedars
 * @notice Tests are intentionally kept very simple.
 * Fuzziness is introduced in integration tests.
 */

contract PointsForLoyaltyVouchersTest is Test {
    /**
     * events
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(
        address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values
    );
    event LoyaltyGiftDeployed(address indexed issuer, uint256[] isVoucher);

    uint256 keyZero = vm.envUint("DEFAULT_ANVIL_KEY_0");
    address addressZero = vm.addr(keyZero);
    uint256 keyOne = vm.envUint("DEFAULT_ANVIL_KEY_1");
    address addressOne = vm.addr(keyOne);

    uint256[] VOUCHERS_TO_MINT = [1];
    uint256[] AMOUNT_VOUCHERS_TO_MINT = [24];
    uint256[] NON_TOKENISED_TO_MINT = [0];
    uint256[] AMOUNT_NON_TOKENISED_TO_MINT = [1];

    ///////////////////////////////////////////////
    ///                   Setup                 ///
    ///////////////////////////////////////////////

    LoyaltyGift loyaltyGift;

    function setUp() external {
        DeployPointsForLoyaltyVouchers deployer = new DeployPointsForLoyaltyVouchers();
        loyaltyGift = deployer.run();
    }

    function testLoyaltyGiftHasGifts() public {
        uint256 numberOfGifts = loyaltyGift.getNumberOfGifts();
        assertNotEq(numberOfGifts, 0);
    }

    function testDeployEmitsevent() public {
        uint256[] memory isVoucher = new uint256[](3); 
        isVoucher[0] = 1; isVoucher[1] = 1; isVoucher[2] = 1;

        vm.expectEmit(true, false, false, false);
        emit LoyaltyGiftDeployed(addressZero, isVoucher);

        vm.prank(addressZero);
        new PointsForLoyaltyVouchers(); 
    }

    ///////////////////////////////////////////////
    ///        Minting token / vouchers         ///
    ///////////////////////////////////////////////
    function testLoyaltyVouchersCanBeMinted() public {
        vm.prank(addressZero);
        loyaltyGift.mintLoyaltyVouchers(VOUCHERS_TO_MINT, AMOUNT_VOUCHERS_TO_MINT);

        assertEq(loyaltyGift.balanceOf(addressZero, VOUCHERS_TO_MINT[0]), AMOUNT_VOUCHERS_TO_MINT[0]);
    }

    function testMintingVouchersEmitsEvent() public {
        vm.expectEmit(true, false, false, false, address(loyaltyGift));
        emit TransferSingle(
            addressZero, // address indexed operator,
            address(0), // address indexed from,
            addressZero, // address indexed to,
            VOUCHERS_TO_MINT[0],
            AMOUNT_VOUCHERS_TO_MINT[0]
        );

        vm.prank(addressZero);
        loyaltyGift.mintLoyaltyVouchers(VOUCHERS_TO_MINT, AMOUNT_VOUCHERS_TO_MINT);
    }

    ///////////////////////////////////////////////
    ///            Issuing gifts                ///
    ///////////////////////////////////////////////
    function testReturnsTrueForSuccess() public {
        vm.startPrank(addressZero);
        
        bool result = loyaltyGift.requirementsLoyaltyGiftMet(addressOne, 1, 5000);
        
        vm.stopPrank();

        assertEq(result, true);
    }

    // For further testing, see integration tests.
   
}
