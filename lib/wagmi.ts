import { http, createConfig } from 'wagmi'
import { baseSepolia, sepolia } from 'wagmi/chains'
import { injected, metaMask, walletConnect } from 'wagmi/connectors'

// Get RPC URL from environment, fallback to public RPCs
const getRpcUrl = (chainId: number) => {
  if (chainId === baseSepolia.id) {
    return (
      process.env.NEXT_PUBLIC_RPC_URL_BASE_SEPOLIA ||
      'https://sepolia.base.org'
    )
  }
  if (chainId === sepolia.id) {
    return (
      process.env.NEXT_PUBLIC_RPC_URL_SEPOLIA ||
      'https://rpc.sepolia.org'
    )
  }
  return undefined
}

export const config = createConfig({
  chains: [baseSepolia, sepolia],
  connectors: [
    injected(),
    metaMask(),
    ...(process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID
      ? [
          walletConnect({
            projectId: process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID,
          }),
        ]
      : []),
  ],
  transports: {
    [baseSepolia.id]: http(getRpcUrl(baseSepolia.id)),
    [sepolia.id]: http(getRpcUrl(sepolia.id)),
  },
})

declare module 'wagmi' {
  interface Register {
    config: typeof config
  }
}

