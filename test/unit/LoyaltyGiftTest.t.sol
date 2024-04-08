// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MockLoyaltyProgram} from "../mocks/MockLoyaltyProgram.sol";
import {LoyaltyGift} from "../../src/LoyaltyGift.sol";
import {DeployPointsForLoyaltyGifts} from "../../script/DeployPointsForLoyaltyGifts.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";


contract LoyaltyGiftsTest is Test {
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

    string GIFT_URI = "https://aqua-famous-sailfish-288.mypinata.cloud/ipfs/QmX24aGKazfEtBzDip4fS6Jb7MnXd9GbFw5oQ3ZqiRKb3t/{id}"; 
    uint256[] isClaimable = [1, 1, 0, 0]; 
    uint256[] isVoucher = [0, 1, 0, 1]; 
    uint256[] cost = [2500, 4500, 2500, 4500];
    uint256[] hasAdditionalRequirements = [0, 0, 1, 1];   
    LoyaltyGift loyaltyGift;

    uint256[] VOUCHER_TO_MINT = [2, 4];
    uint256[] AMOUNT_VOUCHER_TO_MINT = [25, 12];
    uint256[] NON_VOUCHER_TO_MINT = [0];
    uint256[] AMOUNT_NON_VOUCHER_TO_MINT = [1];

    function setUp() external {
        DeployPointsForLoyaltyGifts deployer = new DeployPointsForLoyaltyGifts();
        loyaltyGift = deployer.run();
    }

    function testDeployEmitsevent() public {
        vm.expectEmit(true, false, false, false);
        emit LoyaltyGiftDeployed(addressZero);

        vm.prank(addressZero);
        loyaltyGift = new LoyaltyGift(
        GIFT_URI,  
        isClaimable,
        isVoucher,
        cost,
        hasAdditionalRequirements 
        );
    }

    function testVouchersCanBeMinted() public {

        vm.prank(addressZero);
        loyaltyGift.mintLoyaltyVouchers(VOUCHER_TO_MINT, AMOUNT_VOUCHER_TO_MINT); 

        assertEq(loyaltyGift.balanceOf(addressZero, 2),  AMOUNT_VOUCHER_TO_MINT[0]); 
    }

    function testNonVouchersCannotBeMinted() public {

    }



}