import Link from 'next/link'

export default function About() {
  return (
    <main className="min-h-screen p-8">
      <div className="max-w-3xl mx-auto space-y-8">
        <nav className="mb-12">
          <Link href="/" className="text-gray-400 hover:text-gray-200">
            ← Back
          </Link>
        </nav>
        <h1 className="text-4xl font-light">About</h1>
        <div className="space-y-6 text-gray-300 leading-relaxed">
          <p>
            Focused on protocol design, smart contract architecture, and
            on-chain systems. Interested in mechanisms that work without
            intermediaries.
          </p>
          <p>
            Prefer building over talking. Code over concepts. Execution over
            explanation.
          </p>
          <p>
            This portfolio is itself on-chain. Projects are recorded
            immutably—proof of work, not proof of marketing.
          </p>
        </div>
      </div>
    </main>
  )
}

