// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {PortfolioRegistry} from "../../src/PortfolioRegistry.sol";
import {OnchainIdentityNFT} from "../../src/OnchainIdentityNFT.sol";

/**
 * @title DeployAll
 * @notice Deployment script for all contracts
 * @dev Deploys both PortfolioRegistry and OnchainIdentityNFT to Sepolia
 * 
 * Usage:
 * forge script script/deploy/DeployAll.s.sol:DeployAll \
 *   --rpc-url sepolia \
 *   --private-key $PRIVATE_KEY \
 *   --broadcast \
 *   --verify
 */
contract DeployAll is Script {
    function run() external returns (address registry, address nft) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.envAddress("OWNER_ADDRESS");

        console.log("=== Deploying All Contracts ===");
        console.log("Owner address:", owner);
        console.log("Deployer address:", vm.addr(deployerPrivateKey));

        vm.startBroadcast(deployerPrivateKey);

        // Deploy PortfolioRegistry
        console.log("\n--- Deploying PortfolioRegistry ---");
        PortfolioRegistry portfolioRegistry = new PortfolioRegistry(owner);
        console.log("PortfolioRegistry deployed at:", address(portfolioRegistry));

        // Deploy OnchainIdentityNFT
        console.log("\n--- Deploying OnchainIdentityNFT ---");
        OnchainIdentityNFT identityNFT = new OnchainIdentityNFT(
            "Onchain Identity",
            "OID"
        );
        console.log("OnchainIdentityNFT deployed at:", address(identityNFT));

        vm.stopBroadcast();

        console.log("\n=== Deployment Summary ===");
        console.log("PortfolioRegistry:", address(portfolioRegistry));
        console.log("OnchainIdentityNFT:", address(identityNFT));

        return (address(portfolioRegistry), address(identityNFT));
    }
}

