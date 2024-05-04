// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {LoyaltyProgram} from "../mocks/LoyaltyProgram.t.sol";
import {LoyaltyGift} from "../../src/LoyaltyGift.sol";
import {DeployPointsForLoyaltyVouchers} from "../../script/DeployPointsForLoyaltyVouchers.s.sol";
import {DeployLoyaltyProgram} from "../../script/DeployLoyaltyProgram.s.sol";
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
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
    event LoyaltyGiftDeployed(address indexed issuer, string indexed version);

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
    LoyaltyProgram loyaltyProgram;
    HelperConfig helperConfig; 

    function setUp() external {
        string memory rpc_url = vm.envString("SELECTED_RPC_URL"); 
        uint256 forkId = vm.createFork(rpc_url);
        vm.selectFork(forkId);

        DeployPointsForLoyaltyVouchers deployer = new DeployPointsForLoyaltyVouchers();
        loyaltyGift = deployer.run();

        DeployLoyaltyProgram deployerProgram = new DeployLoyaltyProgram();
        (loyaltyProgram, helperConfig)  = deployerProgram.run();
    }

    function testLoyaltyGiftHasGifts() public {
        uint256 numberOfGifts = loyaltyGift.getNumberOfGifts();
        assertNotEq(numberOfGifts, 0);
    }

    function testDeployEmitsevent() public {
        uint256[] memory isVoucher = new uint256[](3); 
        string memory version = "alpha.2";
        isVoucher[0] = 1; isVoucher[1] = 1; isVoucher[2] = 1;

        vm.expectEmit(true, false, false, false);
        emit LoyaltyGiftDeployed(addressZero, version);

        vm.prank(addressZero);
        new PointsForLoyaltyVouchers(); 
    }

    function testGiftCanBeAddedByLoyaltyProgram() public {
      address ownerProgram = loyaltyProgram.getOwner(); 

      vm.prank(ownerProgram);
      loyaltyProgram.addLoyaltyGift(address(loyaltyGift), 0); 
      assertEq(loyaltyProgram.getLoyaltyGiftIsClaimable(address(loyaltyGift), 0), 1); 
    }

    ///////////////////////////////////////////////
    ///        Minting token / vouchers         ///
    ///////////////////////////////////////////////
    function testLoyaltyVouchersCanBeMinted() public {
        address ownerProgram = loyaltyProgram.getOwner(); 

        vm.prank(ownerProgram);
        loyaltyProgram.mintLoyaltyVouchers(address(loyaltyGift), VOUCHERS_TO_MINT, AMOUNT_VOUCHERS_TO_MINT);

        assertEq(loyaltyGift.balanceOf(ownerProgram, VOUCHERS_TO_MINT[0]), AMOUNT_VOUCHERS_TO_MINT[0]);
    }

    function testMintingVouchersEmitsEvent() public {
        address ownerProgram = loyaltyProgram.getOwner(); 

        vm.expectEmit(true, false, false, false, address(loyaltyGift));
        emit TransferSingle(
            address(loyaltyProgram), // address indexed operator,
            address(0), // address indexed from,
            ownerProgram, // address indexed to,
            VOUCHERS_TO_MINT[0],
            AMOUNT_VOUCHERS_TO_MINT[0]
        );

        vm.prank(ownerProgram);
        loyaltyProgram.mintLoyaltyVouchers(address(loyaltyGift), VOUCHERS_TO_MINT, AMOUNT_VOUCHERS_TO_MINT);
    }

    ///////////////////////////////////////////////
    ///     test RequiremntMet                  ///
    ///////////////////////////////////////////////



    // For further testing, see integration tests.
   
}
