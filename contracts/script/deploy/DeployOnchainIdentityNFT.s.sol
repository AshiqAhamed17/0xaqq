// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {OnchainIdentityNFT} from "../../src/OnchainIdentityNFT.sol";

/**
 * @title DeployOnchainIdentityNFT
 * @notice Deployment script for OnchainIdentityNFT contract
 * @dev Deploys to Sepolia testnet with name and symbol
 *
 * Usage:
 * forge script script/deploy/DeployOnchainIdentityNFT.s.sol:DeployOnchainIdentityNFT \
 *   --rpc-url sepolia \
 *   --private-key $PRIVATE_KEY \
 *   --broadcast \
 *   --verify
 */
contract DeployOnchainIdentityNFT is Script {
    function run() external returns (address) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        string memory name = "Onchain Identity";
        string memory symbol = "OID";

        console.log("Deploying OnchainIdentityNFT...");
        console.log("Name:", name);
        console.log("Symbol:", symbol);
        console.log("Deployer address:", vm.addr(deployerPrivateKey));

        vm.startBroadcast(deployerPrivateKey);

        OnchainIdentityNFT nft = new OnchainIdentityNFT(name, symbol);

        vm.stopBroadcast();

        console.log("OnchainIdentityNFT deployed at:", address(nft));
        console.log("Name:", nft.name());
        console.log("Symbol:", nft.symbol());

        return address(nft);
    }
}
