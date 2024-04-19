// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {LoyaltyProgram} from "../mocks/LoyaltyProgram.t.sol";
import {LoyaltyGift} from "../../src/LoyaltyGift.sol";
import {DeployPointsForLoyaltyGifts} from "../../script/DeployPointsForLoyaltyGifts.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";


contract LoyaltyGiftsTest is Test {
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

    string GIFT_URI = "https://aqua-famous-sailfish-288.mypinata.cloud/ipfs/QmX24aGKazfEtBzDip4fS6Jb7MnXd9GbFw5oQ3ZqiRKb3t/{id}"; 
    uint256[] isClaimable = [1, 1]; 
    uint256[] isVoucher = [0, 1]; 
    uint256[] cost = [2500, 4500];
    uint256[] hasAdditionalRequirements = [0, 0];   
    LoyaltyGift loyaltyGift;
    LoyaltyProgram loyaltyProgram; 

    ///////////////////////////////////////////
    ///            Setup                    ///
    ///////////////////////////////////////////
    function setUp() external {
        HelperConfig helperConfig = new HelperConfig();
        string memory name = "Loyalty Program"; 
        string memory version = "1";

        (, string memory uri,,,, address erc65511Implementation,) =
            helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        loyaltyGift = new LoyaltyGift(
        GIFT_URI,  
        isClaimable,
        isVoucher,
        cost,
        hasAdditionalRequirements 
        );

        loyaltyProgram = new LoyaltyProgram(
            uri, 
            name,
            version,
            payable(erc65511Implementation)
        ); 
        vm.stopBroadcast();
    }

    function testDeployEmitsevent() public {
        vm.expectEmit(true, false, false, false);
        emit LoyaltyGiftDeployed(addressZero, isVoucher);

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
    ///          Minting Vouchers                ///
    ///////////////////////////////////////////////
    function testVouchersCanBeMinted() public {
        uint256[] memory voucherId = new uint256[](1); // only emmpty fixed arrays can be initiated in memory 
        voucherId[0] = 1; 
        uint256[] memory numberOfVouchers = new uint256[](1); 
        numberOfVouchers[0] = 25;
        address owner = loyaltyProgram.getOwner(); 

        vm.prank(owner);
        loyaltyProgram.mintLoyaltyVouchers(address(loyaltyGift), voucherId, numberOfVouchers);

        assertEq(loyaltyGift.balanceOf(owner, voucherId[0]), numberOfVouchers[0]);
    }

    function testNonVouchersCannotBeMinted() public {
        uint256[] memory voucherId = new uint256[](1); // only emmpty fixed arrays can be initiated in memory 
        voucherId[0] = 0; 
        uint256[] memory numberOfVouchers = new uint256[](1); 
        numberOfVouchers[0] = 25;
        address owner = loyaltyProgram.getOwner(); 

        vm.expectRevert(
            abi.encodeWithSelector(
                LoyaltyGift.LoyaltyGift__IsNotVoucher.selector, address(loyaltyGift), voucherId[0]
            )
        );

        vm.prank(owner);
        loyaltyProgram.mintLoyaltyVouchers(address(loyaltyGift), voucherId, numberOfVouchers);
    }
}

    ///////////////////////////////////////////////
    ///        Transferring vouchers            ///
    ///////////////////////////////////////////////

    
//     function testRevertIssuingNonVoucher() public {
//         uint256 voucherId = 0; 

//         vm.expectRevert(
//             abi.encodeWithSelector(
//                 LoyaltyGift.LoyaltyGift__IsNotVoucher.selector, address(loyaltyGift), voucherId
//             )
//         );

//         vm.prank(addressZero);
//         loyaltyGift.safeTransferFrom(
//             addressOne, voucherId
//             );
//     }

//     function testRevertIssuingVoucherWhenNoneAvailable() public {
//         uint256 voucherId = 1; 

//         vm.expectRevert(
//             abi.encodeWithSelector(
//                 LoyaltyGift.LoyaltyGift__NoVouchersAvailable.selector, address(loyaltyGift)
//             )
//         );

//         vm.prank(addressZero);
//         loyaltyGift.issueLoyaltyVoucher(addressOne, voucherId);        
//     }

//     function testVoucherIsIssued() public {
//         uint256[] memory voucherId = new uint256[](1); // only emmpty fixed arrays can be initiated in memory 
//         voucherId[0] = 1; 
//         uint256[] memory numberOfVouchers = new uint256[](1); 
//         numberOfVouchers[0] = 25;
//         address ownerProgram = loyaltyProgram.getOwner(); 

//         // step 1: owner mints cards and points. 
//         vm.startPrank(ownerProgram);
//         loyaltyProgram.mintLoyaltyCards(5); 
//         loyaltyProgram.mintLoyaltyPoints(50_000); 
//         vm.stopPrank();

//         // step 2: get address of TBA of card no 1. 
//         address loyaltyCardAddress = loyaltyProgram.getTokenBoundAddress(1); 

//         // step 3a: owner transfers points to card 1 & transfers card 1 to addressZero. 
//         vm.startPrank(ownerProgram);
//         loyaltyProgram.safeTransferFrom(
//             ownerProgram, loyaltyCardAddress, 0, 10_000, ""
//         ); 
//         loyaltyProgram.safeTransferFrom(
//             ownerProgram, addressZero, 1, 1, ""
//         );

//         // step 3b: owner adds gift & mints its vouchers. 
//         loyaltyProgram.addLoyaltyGift(address(loyaltyGift), voucherId[0]); 
//         loyaltyProgram.mintLoyaltyVouchers(address(loyaltyGift), voucherId, numberOfVouchers);
//         vm.stopPrank(); 

//         // step 4: loyalty program is called to transfer vouchers to loyalty card (vouchers are owned by loyaltyProgram, not the owner of the program!). 
//         vm.prank(address(loyaltyProgram));
//         loyaltyGift.issueLoyaltyVoucher(loyaltyCardAddress, voucherId[0]); 
        
//         assertEq(loyaltyGift.balanceOf(loyaltyCardAddress, voucherId[0]), 1); 
//     }

//     //////////////////////////////////////////////
//     ///            Redeem vouchers             ///
//     //////////////////////////////////////////////
//     function testRedeemRevertsForNonAvailableTokenisedGift() public {
//         uint256 nonVoucherId = 0; 

//         vm.expectRevert(
//             abi.encodeWithSelector(
//                 LoyaltyGift.LoyaltyGift__IsNotVoucher.selector, address(loyaltyGift), nonVoucherId
//             )
//         );
//         vm.prank(addressZero);
//         loyaltyGift.redeemLoyaltyVoucher(address(0), nonVoucherId);
//     }

//     function testVouchercanBeRedeemed() public {
//         uint256[] memory voucherId = new uint256[](1); // only emmpty fixed arrays can be initiated in memory 
//         voucherId[0] = 1; 
//         uint256[] memory numberOfVouchers = new uint256[](1); 
//         numberOfVouchers[0] = 25;
//         address ownerProgram = loyaltyProgram.getOwner(); 

//         // step 1: owner mints cards and points. 
//         vm.startPrank(ownerProgram);
//         loyaltyProgram.mintLoyaltyCards(5); 
//         loyaltyProgram.mintLoyaltyPoints(50_000); 
//         vm.stopPrank();

//         // step 2: get address of TBA of card no 1. 
//         address loyaltyCardAddress = loyaltyProgram.getTokenBoundAddress(1); 

//         // step 3a: owner transfers points to card 1 & transfers card 1 to addressZero. 
//         vm.startPrank(ownerProgram);
//         loyaltyProgram.safeTransferFrom(
//             ownerProgram, loyaltyCardAddress, 0, 10_000, ""
//         ); 
//         loyaltyProgram.safeTransferFrom(
//             ownerProgram, addressZero, 1, 1, ""
//         );

//         // step 3b: owner adds gift & mints its vouchers. 
//         loyaltyProgram.addLoyaltyGift(address(loyaltyGift), voucherId[0]); 
//         loyaltyProgram.mintLoyaltyVouchers(address(loyaltyGift), voucherId, numberOfVouchers);
//         vm.stopPrank(); 

//         // step 4: loyalty program is called to transfer vouchers to loyalty card (vouchers are owned by loyaltyProgram, not the owner of the program!). 
//         vm.prank(address(loyaltyProgram));
//         loyaltyGift.issueLoyaltyVoucher(loyaltyCardAddress, voucherId[0]); 
        
//         assertEq(loyaltyGift.balanceOf(loyaltyCardAddress, voucherId[0]), 1);

//         vm.prank(address(loyaltyProgram));
//         loyaltyGift.redeemLoyaltyVoucher(loyaltyCardAddress, voucherId[0]);   
//     }
// }