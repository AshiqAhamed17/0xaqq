# 0xaqq.eth Portfolio Contracts

Smart contracts for the on-chain portfolio registry and identity NFT.

## Contracts

- `PortfolioRegistry.sol` - Immutable on-chain project registry
- `OnchainIdentityNFT.sol` - Soulbound ERC721 identity badge

## Setup

1. Copy `.env.example` to `.env` and fill in your values:
   ```bash
   cp .env.example .env
   ```

2. Install dependencies (if needed):
   ```bash
   forge install OpenZeppelin/openzeppelin-contracts
   ```

## Build

```bash
forge build
```

## Test

```bash
forge test
```

## Deploy

Deployment scripts are in `script/deploy/`:

```bash
# Deploy to Base Sepolia
forge script script/deploy/DeployPortfolioRegistry.s.sol:DeployPortfolioRegistry \
  --rpc-url base_sepolia \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

## Project Structure

```
contracts/
├── src/              # Smart contracts
├── test/             # Foundry tests
├── script/           # Deployment scripts
│   └── deploy/       # Deployment scripts
└── lib/              # Dependencies (forge-std, openzeppelin, etc.)
```
