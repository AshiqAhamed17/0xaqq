// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";

/**
 * @title SaveAddresses
 * @notice Helper script to save contract addresses to .env file
 * @dev Run this after deployment to update .env with contract addresses
 * 
 * Usage:
 * forge script script/deploy/SaveAddresses.s.sol:SaveAddresses \
 *   --sig "save(address,address)" \
 *   <PORTFOLIO_REGISTRY_ADDRESS> <IDENTITY_NFT_ADDRESS>
 */
contract SaveAddresses is Script {
    function save(
        address portfolioRegistry,
        address identityNFT
    ) external {
        console.log("=== Contract Addresses ===");
        console.log("PortfolioRegistry:");
        console.logAddress(portfolioRegistry);
        console.log("OnchainIdentityNFT:");
        console.logAddress(identityNFT);
        console.log("");
        console.log("Please manually update your .env files with these addresses.");
        console.log("See DEPLOYMENT.md for instructions.");
    }
}

