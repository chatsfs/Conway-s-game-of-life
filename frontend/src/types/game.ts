// Cell coordinate
export interface Cell {
  row: number;
  col: number;
}

// Game state from API
export interface Game {
  id: number;
  width: number;
  height: number;
  generation: number;
  population: number;
  created_at?: string;
  updated_at?: string;
}

// Grid state (2D array of booleans)
export type Grid = boolean[][];

// Next state preview response
export interface NextStateResponse {
  grid: Grid;
  generation: number;
  population: number;
}

// Analysis response
export interface GameAnalysis {
  population: number;
  generation: number;
  stable: boolean;
  extinct: boolean;
  oscillating: boolean;
  oscillation_period: number | null;
  bounds: {
    min_row: number;
    max_row: number;
    min_col: number;
    max_col: number;
    width: number;
    height: number;
  };
}

// Export response
export interface GameExport {
  grid: Grid;
  rle: string;
  alive_cells: Cell[];
}

// Final state response
export interface FinalStateResponse {
  final_generation: number;
  reason: "stable" | "oscillating" | "extinct";
  population: number;
  oscillation_period: number | null;
}

// Create game request
export interface CreateGameRequest {
  width: number;
  height: number;
}

// Set cells request
export interface SetCellsRequest {
  cells: Cell[];
}

// Randomize request
export interface RandomizeRequest {
  density: number; // 0.0 to 1.0
}

// Advance states request
export interface AdvanceStatesRequest {
  states: number;
}

// Final state request
export interface FinalStateRequest {
  max_generations?: number;
}

// API Error response
export interface ApiError {
  error: string;
  details?: unknown;
}
