// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {LoyaltyGift} from "../src/LoyaltyGift.sol";
import {Script, console} from "forge-std/Script.sol"; 

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 chainid;
        uint256 interval;
        uint32 callbackGasLimit;
    }
    NetworkConfig public activeNetworkConfig;

    /**
     * @notice for now only includes test networks.
     * 
     * @dev 80001 = mumbai  
     * @dev 11155420 = OPSepolia 
     * @dev 11155420 = BaseSepolia
     * @dev 421614 = arbitrumSepolia 
     */
    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        }
        if (block.chainid == 421614) {
            activeNetworkConfig = getArbitrumSepoliaEthConfig(); // Arbitrum testnetwork
        }
        else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            chainid: 11155111,
            interval: 30,
            callbackGasLimit: 50000
        });
        return sepoliaConfig;
    }

    function getArbitrumSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory arbitrumSepoliaConfig = NetworkConfig({
            chainid: 421614,
            interval: 30,
            callbackGasLimit: 50000
        });
        return arbitrumSepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public pure returns (NetworkConfig memory) {

        NetworkConfig memory anvilConfig = NetworkConfig({
            chainid: 31337,
            interval: 30,
            callbackGasLimit: 50000
        });
        return anvilConfig;
    }
}
