import { create } from "zustand";
import { Cell } from "@/types/game";

interface GameUIState {
  // Current game ID
  currentGameId: number | null;
  setCurrentGameId: (id: number | null) => void;

  // Animation state
  isPlaying: boolean;
  setIsPlaying: (playing: boolean) => void;
  togglePlaying: () => void;

  // Animation speed (generations per second)
  speed: number;
  setSpeed: (speed: number) => void;

  // Grid dimensions
  gridWidth: number;
  gridHeight: number;
  setGridDimensions: (width: number, height: number) => void;

  // Selected cells (for editing)
  selectedCells: Set<string>;
  toggleCell: (row: number, col: number) => void;
  clearSelection: () => void;
  getSelectedCells: () => Cell[];

  // UI state
  showAnalysis: boolean;
  setShowAnalysis: (show: boolean) => void;
  showPatterns: boolean;
  setShowPatterns: (show: boolean) => void;
}

// Helper to convert row,col to string key
const cellKey = (row: number, col: number) => `${row},${col}`;

// Helper to parse cell key back to coordinates
const parseCellKey = (key: string): Cell => {
  const [row, col] = key.split(",").map(Number);
  return { row, col };
};

export const useGameStore = create<GameUIState>((set, get) => ({
  currentGameId: null,
  setCurrentGameId: (id) => set({ currentGameId: id }),

  isPlaying: false,
  setIsPlaying: (playing) => set({ isPlaying: playing }),
  togglePlaying: () => set((state) => ({ isPlaying: !state.isPlaying })),

  speed: 5, // 5 generations per second by default
  setSpeed: (speed) => set({ speed }),

  gridWidth: 50,
  gridHeight: 50,
  setGridDimensions: (width, height) => set({ gridWidth: width, gridHeight: height }),

  selectedCells: new Set(),
  toggleCell: (row, col) =>
    set((state) => {
      const key = cellKey(row, col);
      const newSet = new Set(state.selectedCells);
      if (newSet.has(key)) {
        newSet.delete(key);
      } else {
        newSet.add(key);
      }
      return { selectedCells: newSet };
    }),
  clearSelection: () => set({ selectedCells: new Set() }),
  getSelectedCells: () => {
    const { selectedCells } = get();
    return Array.from(selectedCells).map(parseCellKey);
  },

  showAnalysis: true,
  setShowAnalysis: (show) => set({ showAnalysis: show }),
  showPatterns: false,
  setShowPatterns: (show) => set({ showPatterns: show }),
}));
