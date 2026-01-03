# Quick Deployment Guide

## Prerequisites

1. Set up `.env` file with:

   - `PRIVATE_KEY=0x...`
   - `OWNER_ADDRESS=0x...` (usually same as deployer)
   - `SEPOLIA_RPC_URL=https://...`
   - `ETHERSCAN_API_KEY=YOUR_KEY_HERE` ⚠️ **Just the key, NOT the full URL!**

   **Important for V2 API**: Your API key should be:

   - ✅ `ETHERSCAN_API_KEY=BP9NQ9Z9Z6V3NZF52UYKHIWSKCNHA8E23I`
   - ❌ NOT: `ETHERSCAN_API_KEY=https://api.etherscan.io/v2/api?chainid=...`

2. Ensure you have Sepolia ETH for gas

## Deploy to Sepolia

### Deploy Both Contracts

**Note**: Due to Etherscan V2 migration, auto-verify might not work. Deploy without `--verify` and verify manually:

```bash
# Deploy without verify (recommended for now)
forge script script/deploy/DeployAll.s.sol:DeployAll \
  --rpc-url sepolia \
  --private-key $PRIVATE_KEY \
  --broadcast \
  -vvvv

# Then verify manually on https://sepolia.etherscan.io/
```

### Deploy PortfolioRegistry Only

```bash
forge script script/deploy/DeployPortfolioRegistry.s.sol:DeployPortfolioRegistry \
  --rpc-url sepolia \
  --private-key $PRIVATE_KEY \
  --broadcast \
  -vvvv
```

### Deploy OnchainIdentityNFT Only

```bash
forge script script/deploy/DeployOnchainIdentityNFT.s.sol:DeployOnchainIdentityNFT \
  --rpc-url sepolia \
  --private-key $PRIVATE_KEY \
  --broadcast \
  -vvvv
```

## After Deployment

1. Copy contract addresses from output
2. Update `.env` files:

   - `contracts/.env`: `PORTFOLIO_REGISTRY_ADDRESS=0x...`
   - `contracts/.env`: `ONCHAIN_IDENTITY_NFT_ADDRESS=0x...`
   - Root `.env.local`: `NEXT_PUBLIC_PORTFOLIO_REGISTRY_ADDRESS=0x...`
   - Root `.env.local`: `NEXT_PUBLIC_IDENTITY_NFT_ADDRESS=0x...`

3. Verify on Etherscan (if auto-verify failed):
   - Go to https://sepolia.etherscan.io/
   - Search contract address
   - Click "Verify and Publish"

## Test Deployment

```bash
# Test PortfolioRegistry
cast send <REGISTRY_ADDRESS> \
  "addProject(string,string)" \
  "Test" "QmHash" \
  --rpc-url sepolia \
  --private-key $PRIVATE_KEY

# Test OnchainIdentityNFT
cast send <NFT_ADDRESS> \
  "mint(uint256,uint8)" \
  75 1 \
  --rpc-url sepolia \
  --private-key $PRIVATE_KEY
```

For detailed instructions, see [DEPLOYMENT.md](../DEPLOYMENT.md)
