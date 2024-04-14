// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {DeployMockLoyaltyProgram} from "../../script/DeployMockLoyaltyProgram.s.sol";
import {MockLoyaltyProgram} from "../mocks/MockLoyaltyProgram.t.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract DeployMockLoyaltyProgramTest is Test {
    DeployMockLoyaltyProgram deployer;
    MockLoyaltyProgram loyaltyProgram;
    HelperConfig helperConfig;
    uint256 LOYALTYCARDS_TO_MINT = 5;

    function setUp() public {
        deployer = new DeployMockLoyaltyProgram();
    }

    function testNameDeployedLoyaltyProgramIsCorrect() public {
        (loyaltyProgram, helperConfig) = deployer.run();
        (, string memory uri,,,,,) = helperConfig.activeNetworkConfig();

        vm.prank(loyaltyProgram.getOwner());
        loyaltyProgram.mintLoyaltyCards(LOYALTYCARDS_TO_MINT);
        string memory actualUri = loyaltyProgram.uri(1);
        assert(keccak256(abi.encodePacked(uri)) == keccak256(abi.encodePacked(actualUri)));
    }
}
