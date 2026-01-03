// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {PortfolioRegistry} from "../../src/PortfolioRegistry.sol";

/**
 * @title DeployPortfolioRegistry
 * @notice Deployment script for PortfolioRegistry contract
 * @dev Deploys to Sepolia testnet with owner set to deployer
 * 
 * Usage:
 * forge script script/deploy/DeployPortfolioRegistry.s.sol:DeployPortfolioRegistry \
 *   --rpc-url sepolia \
 *   --private-key $PRIVATE_KEY \
 *   --broadcast \
 *   --verify
 */
contract DeployPortfolioRegistry is Script {
    function run() external returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.envAddress("OWNER_ADDRESS");

        console.log("Deploying PortfolioRegistry...");
        console.log("Owner address:", owner);
        console.log("Deployer address:", vm.addr(deployerPrivateKey));

        vm.startBroadcast(deployerPrivateKey);

        PortfolioRegistry registry = new PortfolioRegistry(owner);

        vm.stopBroadcast();

        console.log("PortfolioRegistry deployed at:", address(registry));
        console.log("Owner set to:", registry.owner());

        return address(registry);
    }
}

