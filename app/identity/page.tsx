'use client'

import Link from 'next/link'
import { useAccount } from 'wagmi'

export default function Identity() {
  const { address, isConnected } = useAccount()

  return (
    <main className="min-h-screen p-8">
      <div className="max-w-3xl mx-auto space-y-8">
        <nav className="mb-12">
          <Link href="/" className="text-gray-400 hover:text-gray-200">
            ← Back
          </Link>
        </nav>
        <h1 className="text-4xl font-light">Onchain Identity</h1>
        <div className="space-y-6">
          {isConnected ? (
            <div className="space-y-4">
              <p className="text-gray-300">
                Connected: {address}
              </p>
              <p className="text-gray-400">
                Activity score calculation and NFT minting will be implemented
                here.
              </p>
            </div>
          ) : (
            <div className="space-y-4">
              <p className="text-gray-400">
                Connect your wallet to view your on-chain activity score and
                claim your identity NFT.
              </p>
              <p className="text-sm text-gray-500">
                Wallet connection is optional. All other content is accessible
                without a wallet.
              </p>
            </div>
          )}
        </div>
      </div>
    </main>
  )
}

