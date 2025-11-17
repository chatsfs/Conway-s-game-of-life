"use client";

import { useState } from "react";
import { Sparkles, X } from "lucide-react";
import { PATTERNS, Pattern, centerPattern } from "@/lib/patterns";

interface PatternLibraryProps {
  onSelectPattern: (cells: Pattern["cells"]) => void;
  gridWidth: number;
  gridHeight: number;
  disabled?: boolean;
}

export function PatternLibrary({
  onSelectPattern,
  gridWidth,
  gridHeight,
  disabled = false,
}: PatternLibraryProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState<Pattern["category"] | "all">("all");

  const categories: { value: Pattern["category"] | "all"; label: string }[] = [
    { value: "all", label: "All" },
    { value: "still-life", label: "Still Lifes" },
    { value: "oscillator", label: "Oscillators" },
    { value: "spaceship", label: "Spaceships" },
    { value: "methuselah", label: "Methuselahs" },
  ];

  const filteredPatterns =
    selectedCategory === "all"
      ? PATTERNS
      : PATTERNS.filter((p) => p.category === selectedCategory);

  const handleSelectPattern = (pattern: Pattern) => {
    const centeredCells = centerPattern(pattern.cells, gridWidth, gridHeight);
    onSelectPattern(centeredCells);
    setIsOpen(false);
  };

  return (
    <>
      {/* Trigger Button */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        disabled={disabled}
        className="flex items-center gap-2 rounded-lg bg-indigo-600 px-4 py-2 font-medium text-white transition-colors hover:bg-indigo-700 disabled:cursor-not-allowed disabled:opacity-50"
      >
        <Sparkles className="h-4 w-4" />
        Pattern Library
      </button>

      {/* Modal */}
      {isOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4">
          <div className="max-h-[90vh] w-full max-w-3xl overflow-hidden rounded-xl border border-slate-700 bg-slate-900 shadow-2xl">
            {/* Header */}
            <div className="flex items-center justify-between border-b border-slate-700 p-4">
              <h2 className="text-xl font-bold text-white">Pattern Library</h2>
              <button
                onClick={() => setIsOpen(false)}
                className="rounded-lg p-2 text-slate-400 transition-colors hover:bg-slate-800 hover:text-white"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            {/* Category Filter */}
            <div className="border-b border-slate-700 p-4">
              <div className="flex flex-wrap gap-2">
                {categories.map((cat) => (
                  <button
                    key={cat.value}
                    onClick={() => setSelectedCategory(cat.value)}
                    className={`rounded-lg px-4 py-2 text-sm font-medium transition-colors ${
                      selectedCategory === cat.value
                        ? "bg-indigo-600 text-white"
                        : "bg-slate-800 text-slate-300 hover:bg-slate-700"
                    }`}
                  >
                    {cat.label}
                  </button>
                ))}
              </div>
            </div>

            {/* Patterns Grid */}
            <div className="max-h-[60vh] overflow-y-auto p-4">
              <div className="grid gap-4 sm:grid-cols-2">
                {filteredPatterns.map((pattern) => (
                  <button
                    key={pattern.name}
                    onClick={() => handleSelectPattern(pattern)}
                    className="group rounded-lg border border-slate-700 bg-slate-800/50 p-4 text-left transition-all hover:border-indigo-500 hover:bg-slate-800"
                  >
                    <div className="mb-2 flex items-start justify-between">
                      <h3 className="font-semibold text-white group-hover:text-indigo-400">
                        {pattern.name}
                      </h3>
                      <span className="rounded bg-slate-700 px-2 py-1 text-xs text-slate-300">
                        {pattern.category}
                      </span>
                    </div>
                    <p className="text-sm text-slate-400">{pattern.description}</p>
                    <div className="mt-3 text-xs text-slate-500">
                      {pattern.cells.length} cells
                    </div>
                  </button>
                ))}
              </div>

              {filteredPatterns.length === 0 && (
                <div className="py-12 text-center text-slate-400">
                  No patterns found in this category
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </>
  );
}
