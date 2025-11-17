"use client";

import { Play, Pause, SkipForward, RotateCcw, Shuffle, Zap } from "lucide-react";
import { useGameStore } from "@/lib/store";

interface GameControlsProps {
  onStep: () => void;
  onReset: () => void;
  onRandomize: () => void;
  onFindFinal: () => void;
  disabled?: boolean;
  isLoading?: boolean;
}

export function GameControls({
  onStep,
  onReset,
  onRandomize,
  onFindFinal,
  disabled = false,
  isLoading = false,
}: GameControlsProps) {
  const { isPlaying, togglePlaying, speed, setSpeed } = useGameStore();

  return (
    <div className="space-y-4 rounded-lg border border-slate-700 bg-slate-800/50 p-4">
      <div className="flex flex-wrap gap-2">
        {/* Play/Pause */}
        <button
          onClick={togglePlaying}
          disabled={disabled || isLoading}
          className="flex items-center gap-2 rounded-lg bg-green-600 px-4 py-2 font-medium text-white transition-colors hover:bg-green-700 disabled:cursor-not-allowed disabled:opacity-50"
          title={isPlaying ? "Pause" : "Play"}
        >
          {isPlaying ? (
            <>
              <Pause className="h-4 w-4" />
              Pause
            </>
          ) : (
            <>
              <Play className="h-4 w-4" />
              Play
            </>
          )}
        </button>

        {/* Step */}
        <button
          onClick={onStep}
          disabled={disabled || isLoading || isPlaying}
          className="flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2 font-medium text-white transition-colors hover:bg-blue-700 disabled:cursor-not-allowed disabled:opacity-50"
          title="Advance one generation"
        >
          <SkipForward className="h-4 w-4" />
          Step
        </button>

        {/* Reset */}
        <button
          onClick={onReset}
          disabled={disabled || isLoading || isPlaying}
          className="flex items-center gap-2 rounded-lg bg-yellow-600 px-4 py-2 font-medium text-white transition-colors hover:bg-yellow-700 disabled:cursor-not-allowed disabled:opacity-50"
          title="Reset to initial state"
        >
          <RotateCcw className="h-4 w-4" />
          Reset
        </button>

        {/* Randomize */}
        <button
          onClick={onRandomize}
          disabled={disabled || isLoading || isPlaying}
          className="flex items-center gap-2 rounded-lg bg-purple-600 px-4 py-2 font-medium text-white transition-colors hover:bg-purple-700 disabled:cursor-not-allowed disabled:opacity-50"
          title="Fill with random cells"
        >
          <Shuffle className="h-4 w-4" />
          Random
        </button>

        {/* Find Final */}
        <button
          onClick={onFindFinal}
          disabled={disabled || isLoading || isPlaying}
          className="flex items-center gap-2 rounded-lg bg-orange-600 px-4 py-2 font-medium text-white transition-colors hover:bg-orange-700 disabled:cursor-not-allowed disabled:opacity-50"
          title="Jump to final stable/oscillating/extinct state"
        >
          <Zap className="h-4 w-4" />
          Find Final
        </button>
      </div>

      {/* Speed Control */}
      <div className="space-y-2">
        <div className="flex items-center justify-between">
          <label htmlFor="speed" className="text-sm font-medium text-slate-300">
            Speed: {speed} gen/s
          </label>
          <span className="text-xs text-slate-400">{Math.round(1000 / speed)}ms per gen</span>
        </div>
        <input
          id="speed"
          type="range"
          min="1"
          max="30"
          value={speed}
          onChange={(e) => setSpeed(Number(e.target.value))}
          disabled={disabled}
          className="w-full accent-green-600 disabled:opacity-50"
        />
        <div className="flex justify-between text-xs text-slate-400">
          <span>Slow</span>
          <span>Fast</span>
        </div>
      </div>
    </div>
  );
}
