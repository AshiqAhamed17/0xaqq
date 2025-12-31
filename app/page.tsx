import Link from 'next/link'

export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-8">
      <div className="max-w-2xl text-center space-y-8">
        <h1 className="text-5xl font-light tracking-tight">0xaqq.eth</h1>
        <p className="text-lg text-gray-400">
          Protocol engineering and on-chain systems
        </p>
        <div className="flex gap-4 justify-center pt-4">
          <Link
            href="/work"
            className="px-6 py-2 border border-gray-700 hover:border-gray-500 transition-colors"
          >
            View Work
          </Link>
          <Link
            href="/identity"
            className="px-6 py-2 border border-gray-700 hover:border-gray-500 transition-colors"
          >
            Connect Wallet (Optional)
          </Link>
        </div>
      </div>
    </main>
  )
}

