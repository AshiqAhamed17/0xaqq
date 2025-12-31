# 0xaqq.eth Portfolio V1 - Task Breakdown

## Mental Model & Architecture

### Core Principles

- **Public-first**: All content accessible without wallet
- **Progressive enhancement**: Wallet adds features, doesn't gate content
- **On-chain proof**: Portfolio entries stored immutably on-chain
- **Transparent scoring**: Activity score calculated client-side, verifiable
- **Protocol-minded**: Clean, minimal, engineering-focused (no hype)

### Architecture Flow

```
User visits site (no wallet)
  ↓
Views public portfolio (reads PortfolioRegistry from chain)
  ↓
Optionally connects wallet
  ↓
Views activity score (client-side calculation)
  ↓
Optionally mints OnchainIdentityNFT (soulbound badge)
```

### Data Flow

- **Portfolio entries**: Stored on-chain in PortfolioRegistry.sol
- **Metadata**: IPFS hashes stored on-chain, content fetched client-side
- **Activity score**: Calculated client-side via RPC calls (no backend)
- **NFT metadata**: On-chain or IPFS (determined by contract design)

---

## Phase 1: Project Setup & Infrastructure

### 1.1 Initialize Next.js Project

- [ ] Create Next.js 14+ app with App Router
- [ ] Configure TypeScript
- [ ] Set up Tailwind CSS (minimal config)
- [ ] Install dependencies: wagmi, viem, @tanstack/react-query
- [ ] Configure wagmi with testnet (Sepolia or Base Sepolia)
- [ ] Set up environment variables (.env.local)

### 1.2 Initialize Foundry Project

- [ ] Create Foundry project structure
- [ ] Configure foundry.toml (testnet settings)
- [ ] Set up remappings for imports
- [ ] Create deployment scripts structure

### 1.3 Project Structure

- [ ] Create `/app` directory structure:
  - `page.tsx` (landing)
  - `about/page.tsx`
  - `work/page.tsx`
  - `identity/page.tsx`
- [ ] Create `/contracts` directory
- [ ] Create `/test` directory
- [ ] Create `/lib` directory for utilities
- [ ] Create `/components` directory for React components

---

## Phase 2: Smart Contracts

### 2.1 PortfolioRegistry.sol

- [ ] Design contract structure:
  - Owner-only `addProject(title, ipfsHash)`
  - Public `getProjects()` view function
  - Public `getProjectCount()` view function
  - Events: `ProjectAdded(uint256 indexed id, string title, string ipfsHash, uint256 timestamp)`
- [ ] Implement access control (owner)
- [ ] Store projects in array or mapping
- [ ] Include timestamp in project struct
- [ ] Add NatSpec documentation
- [ ] Gas optimization considerations

### 2.2 OnchainIdentityNFT.sol

- [ ] ERC721 base implementation
- [ ] Soulbound logic (override transfer functions to revert)
- [ ] One NFT per wallet (mapping address => tokenId)
- [ ] Tier enum: Bronze, Silver, Gold
- [ ] Mint function that:
  - Checks wallet hasn't minted
  - Accepts tier as parameter (frontend calculates)
  - Stores tier in token metadata
- [ ] Metadata structure:
  - `tier`: Bronze/Silver/Gold
  - `score`: numeric score
  - `mintedAt`: timestamp
- [ ] Consider on-chain vs IPFS metadata (V1: on-chain for simplicity)
- [ ] Add NatSpec documentation

### 2.3 Contract Deployment

- [ ] Create deployment scripts
- [ ] Deploy to testnet (Sepolia or Base Sepolia)
- [ ] Verify contracts on block explorer
- [ ] Store contract addresses in env/config

---

## Phase 3: Foundry Tests

### 3.1 PortfolioRegistry.t.sol

- [ ] Test setup (deploy contract, set owner)
- [ ] Test `addProject()`:
  - Only owner can add
  - Non-owner cannot add
  - Project data stored correctly
  - Event emitted correctly
- [ ] Test `getProjects()`:
  - Returns all projects
  - Returns empty array initially
  - Handles multiple projects
- [ ] Test `getProjectCount()`:
  - Returns correct count
  - Increments on add

### 3.2 OnchainIdentityNFT.t.sol

- [ ] Test setup (deploy contract)
- [ ] Test minting:
  - Can mint once per wallet
  - Cannot mint twice
  - Tier stored correctly
  - TokenId assigned correctly
- [ ] Test soulbound:
  - `transfer()` reverts
  - `transferFrom()` reverts
  - `approve()` can be called but transfer still fails
- [ ] Test metadata:
  - Returns correct tier
  - Returns correct score
  - Returns mint timestamp

---

## Phase 4: Frontend - Core Pages

### 4.1 Landing Page (`/app/page.tsx`)

- [ ] Hero section:
  - ENS name: "0xaqq.eth"
  - Technical one-liner (protocol-focused)
  - Two CTAs: "View Work", "Connect Wallet (Optional)"
- [ ] Dark theme styling
- [ ] Clean typography
- [ ] No Web3 jargon
- [ ] Responsive design

### 4.2 About Page (`/app/about/page.tsx`)

- [ ] Focus on thinking style, not buzzwords
- [ ] Protocol engineering perspective
- [ ] Minimal, text-focused layout
- [ ] No marketing language

### 4.3 Work Page (`/app/work/page.tsx`)

- [ ] Read PortfolioRegistry from chain
- [ ] Display projects:
  - Title
  - Description (fetch from IPFS)
  - "Recorded on-chain at block X"
- [ ] Handle loading states
- [ ] Handle empty state
- [ ] Error handling (RPC failures, contract not deployed)
- [ ] No wallet required (public read)

### 4.4 Identity Page (`/app/identity/page.tsx`)

- [ ] Show activity score (if wallet connected)
- [ ] Display tier preview
- [ ] "Claim Onchain Identity NFT" button
- [ ] Handle minting flow:
  - Check if already minted
  - Calculate score
  - Determine tier
  - Mint NFT
  - Show success state
- [ ] Wallet connection prompt (if not connected)
- [ ] Display minted NFT (if exists)

---

## Phase 5: Frontend - Components & Utilities

### 5.1 Wallet Components

- [ ] `WalletButton.tsx`:
  - Connect/disconnect button
  - Show connected address
  - Show ENS if available
  - Optional mode (never required)
- [ ] `WalletProvider.tsx`:
  - Wrap app with wagmi providers
  - Configure chains (testnet)
  - No auto-connect popups

### 5.2 Portfolio Components

- [ ] `ProjectCard.tsx`:
  - Display project title
  - Fetch and display IPFS content
  - Show block number
  - Loading/error states
- [ ] `ProjectList.tsx`:
  - Fetch projects from contract
  - Render list of ProjectCard
  - Handle pagination if needed

### 5.3 Identity Components

- [ ] `ActivityScore.tsx`:
  - Display score
  - Display tier badge
  - Show breakdown (optional)
- [ ] `IdentityNFT.tsx`:
  - Display NFT if minted
  - Show tier, score, mint date
  - Link to block explorer

### 5.4 Layout Components

- [ ] `Header.tsx`:
  - Navigation
  - Wallet button (optional)
  - ENS highlight if owns 0xaqq.eth
- [ ] `Footer.tsx`:
  - Minimal footer
  - Links (optional)

---

## Phase 6: Activity Scoring Logic

### 6.1 activityScore.ts Implementation

- [ ] Function signature: `calculateActivityScore(address: Address): Promise<{score: number, tier: 'Bronze' | 'Silver' | 'Gold'}>`
- [ ] RPC calls (read-only):
  - Check if address has deployed contracts
  - Check L2/ZK rollup interactions (Base, Arbitrum, Optimism, zkSync)
  - Count transactions (mainnet + L2s)
  - Check Ethereum mainnet interactions
- [ ] Scoring logic:
  - +40: contract deployed
  - +30: L2/ZK rollup interaction
  - +20: >100 transactions
  - +10: Ethereum mainnet interaction
- [ ] Tier calculation:
  - Bronze: 0-49
  - Silver: 50-99
  - Gold: 100+
- [ ] Error handling (RPC failures)
- [ ] Caching considerations (client-side)
- [ ] TypeScript types

### 6.2 RPC Provider Setup

- [ ] Configure providers for:
  - Ethereum mainnet
  - Base Sepolia (or Sepolia)
  - Arbitrum
  - Optimism
  - zkSync (if needed)
- [ ] Handle rate limiting
- [ ] Fallback providers

---

## Phase 7: ENS Integration

### 7.1 ENS Resolution

- [ ] Display ENS name instead of address when available
- [ ] Use wagmi/viem ENS resolution
- [ ] Handle reverse resolution (address => ENS)
- [ ] Cache ENS lookups

### 7.2 0xaqq.eth Highlight

- [ ] Check if connected wallet owns 0xaqq.eth
- [ ] Subtle visual indicator (not flashy)
- [ ] Protocol-minded correctness

---

## Phase 8: IPFS Integration

### 8.1 IPFS Client Setup

- [ ] Choose IPFS client (public gateway or pinata)
- [ ] Fetch IPFS content client-side
- [ ] Handle IPFS errors gracefully
- [ ] Consider caching

### 8.2 Metadata Structure

- [ ] Define JSON schema for project metadata:
  ```json
  {
    "title": "Project Title",
    "description": "Technical description",
    "repo": "github.com/...",
    "tags": ["solidity", "defi"]
  }
  ```
- [ ] Document metadata format

---

## Phase 9: Styling & UX

### 9.1 Tailwind Configuration

- [ ] Minimal color palette (dark theme)
- [ ] Typography scale
- [ ] Spacing system
- [ ] No animation-heavy styles

### 9.2 Design System

- [ ] Button styles
- [ ] Card styles
- [ ] Typography hierarchy
- [ ] Responsive breakpoints

### 9.3 UX Considerations

- [ ] Loading states everywhere
- [ ] Error states
- [ ] Empty states
- [ ] No jarring transitions
- [ ] Accessible (WCAG basics)

---

## Phase 10: Testing & Deployment

### 10.1 Contract Testing

- [ ] Run all Foundry tests
- [ ] Test gas costs
- [ ] Test edge cases
- [ ] Test on testnet

### 10.2 Frontend Testing

- [ ] Test wallet connection flow
- [ ] Test contract reads (no wallet)
- [ ] Test activity score calculation
- [ ] Test NFT minting flow
- [ ] Test ENS resolution
- [ ] Test IPFS fetching
- [ ] Cross-browser testing

### 10.3 Deployment

- [ ] Deploy contracts to testnet
- [ ] Verify contracts
- [ ] Deploy Next.js app (Vercel/Netlify)
- [ ] Configure environment variables
- [ ] Test production build

---

## Phase 11: Documentation

### 11.1 Code Documentation

- [ ] Contract NatSpec comments
- [ ] Function documentation
- [ ] Component documentation
- [ ] Utility function docs

### 11.2 README Updates

- [ ] Project overview
- [ ] Setup instructions
- [ ] Contract addresses
- [ ] Architecture decisions
- [ ] Deployment guide

---

## Technical Decisions & Notes

### Contract Design

- **PortfolioRegistry**: Use array for projects (simple, ordered). Consider gas costs.
- **OnchainIdentityNFT**: On-chain metadata for V1 (simpler, no IPFS dependency for metadata).
- **Soulbound**: Override `_beforeTokenTransfer` to revert all transfers.

### Activity Scoring

- **Client-side only**: No backend, fully transparent.
- **Multi-chain**: Check mainnet + L2s for comprehensive score.
- **Caching**: Cache results in localStorage to avoid repeated RPC calls.

### IPFS

- **Public gateway**: Use public IPFS gateway (ipfs.io) for V1.
- **Fallback**: Handle IPFS gateway failures gracefully.

### Wallet Integration

- **wagmi + viem**: Standard Web3 React stack.
- **No auto-connect**: Respect user privacy, no popups.
- **Progressive enhancement**: All features work without wallet.

### ENS

- **Reverse resolution**: Check if address resolves to ENS.
- **Forward resolution**: Resolve ENS to address for verification.

---

## Dependencies Checklist

### Frontend

- [ ] next
- [ ] react
- [ ] react-dom
- [ ] typescript
- [ ] tailwindcss
- [ ] wagmi
- [ ] viem
- [ ] @tanstack/react-query

### Smart Contracts

- [ ] forge-std (Foundry)
- [ ] OpenZeppelin (for ERC721 base, if used)

### Development

- [ ] foundry
- [ ] node.js
- [ ] npm/yarn/pnpm

---

## Future Considerations (Not V1)

- ZK features
- Backend APIs
- Database
- Blog functionality
- Animation-heavy UI
- Marketing features

---

## Success Criteria

- [ ] Site loads without wallet
- [ ] Portfolio entries readable from chain
- [ ] Wallet connection optional and smooth
- [ ] Activity score calculates correctly
- [ ] NFT mints successfully
- [ ] ENS displays correctly
- [ ] IPFS content loads
- [ ] All tests pass
- [ ] Contracts deployed to testnet
- [ ] Site deployed and accessible
