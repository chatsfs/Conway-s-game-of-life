"use client";

import { Activity, Users, Repeat, CheckCircle2, XCircle, Box } from "lucide-react";
import { GameAnalysis } from "@/types/game";

interface GameInfoProps {
  generation: number;
  population: number;
  analysis?: GameAnalysis;
  isLoading?: boolean;
}

export function GameInfo({ generation, population, analysis, isLoading }: GameInfoProps) {
  return (
    <div className="space-y-4 rounded-lg border border-slate-700 bg-slate-800/50 p-4">
      <h3 className="text-lg font-semibold text-white">Game Stats</h3>

      {/* Basic Stats */}
      <div className="grid grid-cols-2 gap-4">
        <StatCard icon={<Activity className="h-5 w-5" />} label="Generation" value={generation} />
        <StatCard icon={<Users className="h-5 w-5" />} label="Population" value={population} />
      </div>

      {/* Analysis */}
      {analysis && !isLoading && (
        <>
          <div className="border-t border-slate-700 pt-4">
            <h4 className="mb-3 text-sm font-semibold text-slate-300">Pattern Analysis</h4>

            <div className="space-y-2">
              {/* Stability Status */}
              <StatusBadge
                icon={<CheckCircle2 className="h-4 w-4" />}
                label="Stable"
                active={analysis.stable}
                color="green"
              />

              {/* Oscillation Status */}
              <StatusBadge
                icon={<Repeat className="h-4 w-4" />}
                label={
                  analysis.oscillating && analysis.oscillation_period
                    ? `Oscillating (period ${analysis.oscillation_period})`
                    : "Oscillating"
                }
                active={analysis.oscillating}
                color="blue"
              />

              {/* Extinction Status */}
              <StatusBadge
                icon={<XCircle className="h-4 w-4" />}
                label="Extinct"
                active={analysis.extinct}
                color="red"
              />
            </div>
          </div>

          {/* Bounds */}
          {!analysis.extinct && (
            <div className="border-t border-slate-700 pt-4">
              <h4 className="mb-3 flex items-center gap-2 text-sm font-semibold text-slate-300">
                <Box className="h-4 w-4" />
                Pattern Bounds
              </h4>
              <div className="grid grid-cols-2 gap-2 text-sm">
                <div className="rounded bg-slate-900/50 p-2">
                  <div className="text-slate-400">Width</div>
                  <div className="font-mono text-white">{analysis.bounds.width}</div>
                </div>
                <div className="rounded bg-slate-900/50 p-2">
                  <div className="text-slate-400">Height</div>
                  <div className="font-mono text-white">{analysis.bounds.height}</div>
                </div>
                <div className="rounded bg-slate-900/50 p-2">
                  <div className="text-slate-400">Rows</div>
                  <div className="font-mono text-xs text-white">
                    {analysis.bounds.min_row}-{analysis.bounds.max_row}
                  </div>
                </div>
                <div className="rounded bg-slate-900/50 p-2">
                  <div className="text-slate-400">Cols</div>
                  <div className="font-mono text-xs text-white">
                    {analysis.bounds.min_col}-{analysis.bounds.max_col}
                  </div>
                </div>
              </div>
            </div>
          )}
        </>
      )}

      {isLoading && (
        <div className="flex items-center justify-center py-8">
          <div className="h-8 w-8 animate-spin rounded-full border-4 border-slate-600 border-t-green-500"></div>
        </div>
      )}
    </div>
  );
}

function StatCard({
  icon,
  label,
  value,
}: {
  icon: React.ReactNode;
  label: string;
  value: number;
}) {
  return (
    <div className="rounded-lg bg-slate-900/50 p-3">
      <div className="mb-1 flex items-center gap-2 text-slate-400">
        {icon}
        <span className="text-sm">{label}</span>
      </div>
      <div className="text-2xl font-bold text-white">{value.toLocaleString()}</div>
    </div>
  );
}

function StatusBadge({
  icon,
  label,
  active,
  color,
}: {
  icon: React.ReactNode;
  label: string;
  active: boolean;
  color: "green" | "blue" | "red";
}) {
  const colors = {
    green: active
      ? "bg-green-500/20 text-green-400 border-green-500/50"
      : "bg-slate-900/50 text-slate-500 border-slate-700",
    blue: active
      ? "bg-blue-500/20 text-blue-400 border-blue-500/50"
      : "bg-slate-900/50 text-slate-500 border-slate-700",
    red: active
      ? "bg-red-500/20 text-red-400 border-red-500/50"
      : "bg-slate-900/50 text-slate-500 border-slate-700",
  };

  return (
    <div className={`flex items-center gap-2 rounded border px-3 py-2 text-sm ${colors[color]}`}>
      {icon}
      <span className="font-medium">{label}</span>
    </div>
  );
}
