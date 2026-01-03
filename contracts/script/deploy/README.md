# Deployment Scripts

This directory contains deployment scripts for the 0xaqq.eth portfolio contracts.

## Prerequisites

1. Set up your `.env` file:
   ```bash
   cp .env.example .env
   ```

2. Fill in the required environment variables:
   - `PRIVATE_KEY`: Your deployer private key (0x prefix)
   - `OWNER_ADDRESS`: Address that will own PortfolioRegistry (usually same as deployer)
   - `SEPOLIA_RPC_URL`: Sepolia RPC endpoint
   - `ETHERSCAN_API_KEY`: Etherscan API key for verification

3. Ensure you have Sepolia ETH in your deployer wallet for gas fees.

## Deployment Options

### Option 1: Deploy All Contracts

Deploy both contracts in one transaction:

```bash
forge script script/deploy/DeployAll.s.sol:DeployAll \
  --rpc-url sepolia \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  -vvvv
```

### Option 2: Deploy Individually

#### Deploy PortfolioRegistry

```bash
forge script script/deploy/DeployPortfolioRegistry.s.sol:DeployPortfolioRegistry \
  --rpc-url sepolia \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  -vvvv
```

#### Deploy OnchainIdentityNFT

```bash
forge script script/deploy/DeployOnchainIdentityNFT.s.sol:DeployOnchainIdentityNFT \
  --rpc-url sepolia \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  -vvvv
```

## Environment Variables

The scripts use the following environment variables:

- `PRIVATE_KEY`: Private key of the deployer (required)
- `OWNER_ADDRESS`: Owner address for PortfolioRegistry (required for PortfolioRegistry deployment)
- `SEPOLIA_RPC_URL`: Sepolia RPC endpoint (set in foundry.toml or use --rpc-url)
- `ETHERSCAN_API_KEY`: Etherscan API key for verification (set in foundry.toml)

## Verification

Contracts are automatically verified if you use the `--verify` flag. Make sure:

1. `ETHERSCAN_API_KEY` is set in your `.env` file
2. The API key is configured in `foundry.toml` under `[etherscan]`

## After Deployment

1. Copy the deployed contract addresses
2. Update your `.env` file with the addresses:
   ```
   PORTFOLIO_REGISTRY_ADDRESS=0x...
   ONCHAIN_IDENTITY_NFT_ADDRESS=0x...
   ```
3. Update your frontend `.env.local` with the same addresses

## Troubleshooting

### "Insufficient funds"
- Ensure your deployer wallet has Sepolia ETH
- Get testnet ETH from a faucet: https://sepoliafaucet.com/

### "Verification failed"
- Check your `ETHERSCAN_API_KEY` is correct
- Wait a few blocks after deployment before verification
- Try manual verification on Etherscan if automatic fails

### "Nonce too high"
- Reset your nonce or wait for pending transactions to confirm

## Security Notes

- **NEVER** commit your `.env` file to git
- **NEVER** share your private key
- Use a separate wallet for deployments
- Keep your private key secure

