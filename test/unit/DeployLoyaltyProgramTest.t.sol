// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {DeployLoyaltyProgram} from "../../script/DeployLoyaltyProgram.s.sol";
import {LoyaltyProgram} from "../mocks/LoyaltyProgram.t.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract DeployLoyaltyProgramTest is Test {
    DeployLoyaltyProgram deployer;
    LoyaltyProgram loyaltyProgram;
    HelperConfig helperConfig;
    uint256 LOYALTYCARDS_TO_MINT = 5;

    function setUp() public {
        string memory rpc_url = vm.envString("SELECTED_RPC_URL"); 
        uint256 forkId = vm.createFork(rpc_url);
        vm.selectFork(forkId);

        deployer = new DeployLoyaltyProgram();
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
