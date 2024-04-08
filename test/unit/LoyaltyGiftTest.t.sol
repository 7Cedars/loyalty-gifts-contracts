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
    uint256[] isClaimable = [1, 1]; 
    uint256[] isVoucher = [0, 1]; 
    uint256[] cost = [2500, 4500];
    uint256[] hasAdditionalRequirements = [0, 0];   
    LoyaltyGift loyaltyGift;

    uint256[] VOUCHERS_TO_MINT = [2];
    uint256[] AMOUNT_VOUCHERS_TO_MINT = [5];
    uint256[] NON_VOUCHER_TO_MINT = [0];
    uint256[] AMOUNT_NON_VOUCHER_TO_MINT = [1];

    function setUp() external {
        vm.startBroadcast();
        loyaltyGift = new LoyaltyGift(
        GIFT_URI,  
        isClaimable,
        isVoucher,
        cost,
        hasAdditionalRequirements 
        );
        vm.stopBroadcast();
    }

    function testDeployEmitsevent() public {
        vm.expectEmit(true, false, false, false);
        emit LoyaltyGiftDeployed(addressZero);

        vm.prank(addressZero);
        new LoyaltyGift(
        GIFT_URI,  
        isClaimable,
        isVoucher,
        cost,
        hasAdditionalRequirements 
        );
    }
    
    // £fix Gives an odd error. Come back to this later.  
    // function testVouchersCanBeMinted() public {
    //     vm.prank(addressZero);
    //     loyaltyGift.mintLoyaltyVouchers(VOUCHERS_TO_MINT, AMOUNT_VOUCHERS_TO_MINT);

    //     assertEq(loyaltyGift.balanceOf(addressZero, VOUCHERS_TO_MINT[0]), AMOUNT_VOUCHERS_TO_MINT[0]);
    // }

    function testNonVouchersCannotBeMinted() public {

    }



}