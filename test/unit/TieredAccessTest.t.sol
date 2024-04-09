// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {MockLoyaltyProgram} from "../mocks/MockLoyaltyProgram.sol";
import {LoyaltyGift} from "../../src/LoyaltyGift.sol";
import {DeployTieredAccess} from "../../script/DeployTieredAccess.s.sol";
import {TieredAccess} from "../../src/TieredAccess.sol";
import {DeployMockLoyaltyProgram} from "../../script/DeployMockLoyaltyProgram.s.sol";
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
    event LoyaltyGiftDeployed(address indexed issuer);

    uint256 keyZero = vm.envUint("DEFAULT_ANVIL_KEY_0");
    address addressZero = vm.addr(keyZero);
    uint256 keyOne = vm.envUint("DEFAULT_ANVIL_KEY_1");
    address addressOne = vm.addr(keyOne);

    ///////////////////////////////////////////////
    ///                   Setup                 ///
    ///////////////////////////////////////////////

    LoyaltyGift loyaltyGift;
    MockLoyaltyProgram loyaltyProgram; 

    function setUp() external {
        DeployTieredAccess giftDeployer = new DeployTieredAccess();
        loyaltyGift = giftDeployer.run();

        DeployMockLoyaltyProgram programDeployer = new DeployMockLoyaltyProgram();
        (loyaltyProgram, ) = programDeployer.run();
    }

    function testLoyaltyGiftHasGifts() public {
        uint256 numberOfGifts = loyaltyGift.getNumberOfGifts();
        assertNotEq(numberOfGifts, 0);
    }

    function testDeployEmitsevent() public {
        vm.expectEmit(true, false, false, false);
        emit LoyaltyGiftDeployed(addressZero);

        vm.prank(addressZero);
        new TieredAccess(); 
    }

    ///////////////////////////////////////////////
    ///             Requirement test            ///
    ///////////////////////////////////////////////
    

    // all other tests (including for the pseudoRandomNumber function) can be found in fuzz test folder. 

}
