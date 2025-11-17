import { GameContainer } from "@/components/GameContainer";

export default function Home() {
  return (
    <main className="min-h-screen bg-gradient-to-br from-slate-900 via-slate-800 to-slate-900">
      <div className="container mx-auto px-4 py-8">
        <header className="mb-8 text-center">
          <h1 className="mb-2 text-4xl font-bold text-white">Conway&apos;s Game of Life</h1>
          <p className="text-slate-300">
            Explore cellular automaton patterns and watch life evolve
          </p>
        </header>
        <GameContainer />
      </div>
    </main>
  );
}
