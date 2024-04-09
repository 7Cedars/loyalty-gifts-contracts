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
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
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
    MockLoyaltyProgram loyaltyProgram; 

    ///////////////////////////////////////////
    ///            Setup                    ///
    ///////////////////////////////////////////
    function setUp() external {
        HelperConfig helperConfig = new HelperConfig();
        string memory name = "Loyalty Program"; 
        string memory version = "1";

        (, string memory uri,,, address erc65511Registry, address erc65511Implementation,) =
            helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        loyaltyGift = new LoyaltyGift(
        GIFT_URI,  
        isClaimable,
        isVoucher,
        cost,
        hasAdditionalRequirements 
        );

        loyaltyProgram = new MockLoyaltyProgram(
            uri, 
            name,
            version,
            erc65511Registry,
            payable(erc65511Implementation)
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
    
    ///////////////////////////////////////////////
    ///          Mintin Vouchers                ///
    ///////////////////////////////////////////////
    function testVouchersCanBeMinted() public {
        uint256[] memory voucherId = new uint256[](1); // only emmpty fixed arrays can be initiated in memory 
        voucherId[0] = 1; 
        uint256[] memory numberOfVouchers = new uint256[](1); 
        numberOfVouchers[0] = 25;

        vm.prank(addressZero);
        loyaltyGift.mintLoyaltyVouchers(voucherId, numberOfVouchers);

        assertEq(loyaltyGift.balanceOf(addressZero, voucherId[0]), numberOfVouchers[0]);
    }

    function testNonVouchersCannotBeMinted() public {
        uint256[] memory voucherId = new uint256[](1); // only emmpty fixed arrays can be initiated in memory 
        voucherId[0] = 0; 
        uint256[] memory numberOfVouchers = new uint256[](1); 
        numberOfVouchers[0] = 25;

        vm.expectRevert(
            abi.encodeWithSelector(
                LoyaltyGift.LoyaltyGift__IsNotVoucher.selector, address(loyaltyGift), voucherId[0]
            )
        );

        vm.prank(addressZero);
        loyaltyGift.mintLoyaltyVouchers(voucherId, numberOfVouchers);
    }

    ///////////////////////////////////////////////
    ///            Issuing vouchers             ///
    ///////////////////////////////////////////////
    function testRevertIssuingNonVoucher() public {
        uint256 voucherId = 0; 

        vm.expectRevert(
            abi.encodeWithSelector(
                LoyaltyGift.LoyaltyGift__IsNotVoucher.selector, address(loyaltyGift), voucherId
            )
        );

        vm.prank(addressZero);
        loyaltyGift.issueLoyaltyVoucher(addressOne, voucherId);
    }

    function testRevertIssuingVoucherWhenNoneAvailable() public {
        uint256 voucherId = 1; 

        vm.expectRevert(
            abi.encodeWithSelector(
                LoyaltyGift.LoyaltyGift__NoVouchersAvailable.selector, address(loyaltyGift)
            )
        );

        vm.prank(addressZero);
        loyaltyGift.issueLoyaltyVoucher(addressOne, voucherId);        
    }

    // £todo runs into an odd bug. come back to this later.  
    // function testVoucherIsIssued() public {
    //     uint256[] memory voucherId = new uint256[](1); // only emmpty fixed arrays can be initiated in memory 
    //     voucherId[0] = 1; 
    //     uint256[] memory numberOfVouchers = new uint256[](1); 
    //     numberOfVouchers[0] = 25;
    //     address ownerProgram = loyaltyProgram.getOwner(); 

    //     vm.startPrank(ownerProgram);
    //     loyaltyProgram.mintLoyaltyCards(5); 
    //     loyaltyProgram.mintLoyaltyPoints(50_000); 
    //     vm.stopPrank();

    //     address loyaltyCardAddress = loyaltyProgram.getTokenBoundAddress(1); 

    //     vm.startPrank(ownerProgram);
    //     loyaltyProgram.safeTransferFrom(
    //         ownerProgram, loyaltyCardAddress, 0, 10_000, ""
    //     ); 
    //     loyaltyGift.mintLoyaltyVouchers(voucherId, numberOfVouchers);
    //     loyaltyProgram.getBalanceLoyaltyCard(loyaltyCardAddress); 


    //     loyaltyGift.issueLoyaltyVoucher(loyaltyCardAddress, voucherId[0]); 
    //     vm.stopPrank(); 

        // assertEq(loyaltyGift.balanceOf(addressOne, voucherId[0]), 1); 
    // }

    //////////////////////////////////////////////
    ///            Redeem vouchers             ///
    //////////////////////////////////////////////
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

    // £todo implement after fixing test above. 
    // function testVouchercanBeRedeemed() public {
        
    // }
}