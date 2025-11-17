"use client";

import { useEffect, useState } from "react";
import { GameGrid } from "./GameGrid";
import { GameControls } from "./GameControls";
import { GameInfo } from "./GameInfo";
import { PatternLibrary } from "./PatternLibrary";
import { useGameStore } from "@/lib/store";
import {
  useCreateGame,
  useGame,
  useAdvanceGame,
  useSetCells,
  useRandomize,
  useResetGame,
  useFinalState,
  useAnalysis,
  useExport,
} from "@/hooks/useGame";
import { Cell, Grid } from "@/types/game";
import { Download, Loader2 } from "lucide-react";

const DEFAULT_WIDTH = 50;
const DEFAULT_HEIGHT = 50;

export function GameContainer() {
  const {
    currentGameId,
    setCurrentGameId,
    isPlaying,
    setIsPlaying,
    speed,
    gridWidth,
    gridHeight,
    setGridDimensions,
    selectedCells,
    toggleCell,
    clearSelection,
    getSelectedCells,
  } = useGameStore();

  const [currentGrid, setCurrentGrid] = useState<Grid>([]);
  const [isInitializing, setIsInitializing] = useState(true);

  // API hooks
  const createGame = useCreateGame();
  const { data: gameData, isLoading: gameLoading } = useGame(currentGameId);
  const advanceGame = useAdvanceGame();
  const setCells = useSetCells();
  const randomize = useRandomize();
  const resetGame = useResetGame();
  const finalState = useFinalState();
  const { data: analysisData, isLoading: analysisLoading } = useAnalysis(
    currentGameId,
    isPlaying || !!currentGameId
  );
  const { data: exportData, refetch: refetchExport } = useExport(currentGameId);

  // Initialize game on mount
  useEffect(() => {
    const initGame = async () => {
      try {
        const game = await createGame.mutateAsync({
          width: DEFAULT_WIDTH,
          height: DEFAULT_HEIGHT,
        });
        setCurrentGameId(game.id);
        setGridDimensions(game.width, game.height);
        setCurrentGrid(Array(game.height).fill(Array(game.width).fill(false)));
      } catch (error) {
        console.error("Failed to create game:", error);
      } finally {
        setIsInitializing(false);
      }
    };

    initGame();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Fetch grid when game changes
  useEffect(() => {
    const fetchGrid = async () => {
      if (!currentGameId) return;

      try {
        const data = await refetchExport();
        if (data.data?.grid) {
          setCurrentGrid(data.data.grid);
        }
      } catch (error) {
        console.error("Failed to fetch grid:", error);
      }
    };

    fetchGrid();
  }, [currentGameId, gameData?.generation, refetchExport]);

  // Animation loop
  useEffect(() => {
    if (!isPlaying || !currentGameId) return;

    const interval = setInterval(async () => {
      try {
        await advanceGame.mutateAsync(currentGameId);
      } catch (error) {
        console.error("Failed to advance game:", error);
        setIsPlaying(false);
      }
    }, 1000 / speed);

    return () => clearInterval(interval);
  }, [isPlaying, currentGameId, speed, advanceGame, setIsPlaying]);

  // Handlers
  const handleStep = async () => {
    if (!currentGameId) return;
    try {
      await advanceGame.mutateAsync(currentGameId);
    } catch (error) {
      console.error("Failed to step:", error);
    }
  };

  const handleReset = async () => {
    if (!currentGameId) return;
    try {
      await resetGame.mutateAsync(currentGameId);
      clearSelection();
    } catch (error) {
      console.error("Failed to reset:", error);
    }
  };

  const handleRandomize = async () => {
    if (!currentGameId) return;
    try {
      await randomize.mutateAsync({
        id: currentGameId,
        params: { density: 0.3 },
      });
      clearSelection();
    } catch (error) {
      console.error("Failed to randomize:", error);
    }
  };

  const handleFindFinal = async () => {
    if (!currentGameId) return;
    try {
      const result = await finalState.mutateAsync({
        id: currentGameId,
        params: { max_generations: 1000 },
      });
      alert(
        `Final state reached!\nGeneration: ${result.final_generation}\nReason: ${result.reason}\nPopulation: ${result.population}${
          result.oscillation_period ? `\nPeriod: ${result.oscillation_period}` : ""
        }`
      );
    } catch (error) {
      console.error("Failed to find final state:", error);
      alert("Could not find a stable state within 1000 generations");
    }
  };

  const handleCellClick = (row: number, col: number) => {
    if (isPlaying) return;
    toggleCell(row, col);
  };

  const handleApplySelection = async () => {
    if (!currentGameId || selectedCells.size === 0) return;
    try {
      await setCells.mutateAsync({
        id: currentGameId,
        params: { cells: getSelectedCells() },
      });
      clearSelection();
    } catch (error) {
      console.error("Failed to set cells:", error);
    }
  };

  const handleSelectPattern = async (cells: Cell[]) => {
    if (!currentGameId) return;
    try {
      await setCells.mutateAsync({
        id: currentGameId,
        params: { cells },
      });
    } catch (error) {
      console.error("Failed to apply pattern:", error);
    }
  };

  const handleExport = async () => {
    if (!exportData) return;

    const dataStr = JSON.stringify(exportData, null, 2);
    const dataBlob = new Blob([dataStr], { type: "application/json" });
    const url = URL.createObjectURL(dataBlob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `game-${currentGameId}-gen-${gameData?.generation || 0}.json`;
    link.click();
    URL.revokeObjectURL(url);
  };

  if (isInitializing) {
    return (
      <div className="flex min-h-[600px] items-center justify-center">
        <Loader2 className="h-12 w-12 animate-spin text-green-500" />
      </div>
    );
  }

  const isLoading =
    createGame.isPending ||
    advanceGame.isPending ||
    setCells.isPending ||
    randomize.isPending ||
    resetGame.isPending ||
    finalState.isPending;

  return (
    <div className="space-y-6">
      {/* Top Controls */}
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div className="flex flex-wrap gap-2">
          <PatternLibrary
            onSelectPattern={handleSelectPattern}
            gridWidth={gridWidth}
            gridHeight={gridHeight}
            disabled={isPlaying || isLoading}
          />
          {selectedCells.size > 0 && (
            <button
              onClick={handleApplySelection}
              disabled={isPlaying || isLoading}
              className="rounded-lg bg-emerald-600 px-4 py-2 font-medium text-white transition-colors hover:bg-emerald-700 disabled:cursor-not-allowed disabled:opacity-50"
            >
              Apply Selection ({selectedCells.size} cells)
            </button>
          )}
          {selectedCells.size > 0 && (
            <button
              onClick={clearSelection}
              disabled={isPlaying}
              className="rounded-lg bg-slate-600 px-4 py-2 font-medium text-white transition-colors hover:bg-slate-700 disabled:cursor-not-allowed disabled:opacity-50"
            >
              Clear
            </button>
          )}
        </div>

        {exportData && (
          <button
            onClick={handleExport}
            className="flex items-center gap-2 rounded-lg bg-slate-600 px-4 py-2 font-medium text-white transition-colors hover:bg-slate-700"
          >
            <Download className="h-4 w-4" />
            Export
          </button>
        )}
      </div>

      {/* Main Grid */}
      <div className="grid gap-6 lg:grid-cols-[1fr,320px]">
        <div className="flex justify-center">
          <GameGrid
            grid={currentGrid}
            width={gridWidth}
            height={gridHeight}
            onCellClick={handleCellClick}
            highlightCells={selectedCells}
          />
        </div>

        {/* Side Panel */}
        <div className="space-y-6">
          <GameInfo
            generation={gameData?.generation || 0}
            population={gameData?.population || 0}
            analysis={analysisData}
            isLoading={analysisLoading}
          />

          <GameControls
            onStep={handleStep}
            onReset={handleReset}
            onRandomize={handleRandomize}
            onFindFinal={handleFindFinal}
            disabled={!currentGameId}
            isLoading={isLoading}
          />
        </div>
      </div>
    </div>
  );
}
