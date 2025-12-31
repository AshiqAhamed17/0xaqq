import Link from 'next/link'

export default function Work() {
  return (
    <main className="min-h-screen p-8">
      <div className="max-w-3xl mx-auto space-y-8">
        <nav className="mb-12">
          <Link href="/" className="text-gray-400 hover:text-gray-200">
            ← Back
          </Link>
        </nav>
        <h1 className="text-4xl font-light">Work</h1>
        <div className="space-y-6">
          <p className="text-gray-400">
            Projects will be loaded from the on-chain PortfolioRegistry contract
            once deployed.
          </p>
        </div>
      </div>
    </main>
  )
}

