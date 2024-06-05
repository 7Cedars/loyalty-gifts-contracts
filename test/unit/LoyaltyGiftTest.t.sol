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
    event LoyaltyGiftDeployed(address indexed issuer, string indexed version, uint256 indexed numberOfGifts);

    uint256 keyZero = vm.envUint("DEFAULT_ANVIL_KEY_0");
    address addressZero = vm.addr(keyZero);
    uint256 keyOne = vm.envUint("DEFAULT_ANVIL_KEY_1");
    address addressOne = vm.addr(keyOne);

    string GIFT_URI = "https://aqua-famous-sailfish-288.mypinata.cloud/ipfs/QmX24aGKazfEtBzDip4fS6Jb7MnXd9GbFw5oQ3ZqiRKb3t/{id}"; 
    string version = "alpha.3"; 
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
        string memory rpc_url = vm.envString("SELECTED_RPC_URL"); 
        uint256 forkId = vm.createFork(rpc_url);
        vm.selectFork(forkId);

        HelperConfig helperConfig = new HelperConfig();
        string memory name = "Loyalty Program";

        (, string memory uri,,,, address erc65511Implementation,) =
            helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        loyaltyGift = new LoyaltyGift(
        GIFT_URI,
        version,
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
        emit LoyaltyGiftDeployed(addressZero, version, isVoucher.length);

        vm.prank(addressZero);
        new LoyaltyGift(
        GIFT_URI,
        version, 
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
