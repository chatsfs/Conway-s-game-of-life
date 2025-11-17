import { Cell } from "@/types/game";

export interface Pattern {
  name: string;
  description: string;
  category: "still-life" | "oscillator" | "spaceship" | "methuselah";
  cells: Cell[];
}

export const PATTERNS: Pattern[] = [
  // Still Lifes (Static patterns)
  {
    name: "Block",
    description: "The simplest still life - a 2x2 square",
    category: "still-life",
    cells: [
      { row: 1, col: 1 },
      { row: 1, col: 2 },
      { row: 2, col: 1 },
      { row: 2, col: 2 },
    ],
  },
  {
    name: "Beehive",
    description: "A common 6-cell still life",
    category: "still-life",
    cells: [
      { row: 1, col: 2 },
      { row: 1, col: 3 },
      { row: 2, col: 1 },
      { row: 2, col: 4 },
      { row: 3, col: 2 },
      { row: 3, col: 3 },
    ],
  },
  {
    name: "Loaf",
    description: "A 7-cell still life",
    category: "still-life",
    cells: [
      { row: 1, col: 2 },
      { row: 1, col: 3 },
      { row: 2, col: 1 },
      { row: 2, col: 4 },
      { row: 3, col: 2 },
      { row: 3, col: 4 },
      { row: 4, col: 3 },
    ],
  },

  // Oscillators
  {
    name: "Blinker",
    description: "Period-2 oscillator - the most common",
    category: "oscillator",
    cells: [
      { row: 2, col: 1 },
      { row: 2, col: 2 },
      { row: 2, col: 3 },
    ],
  },
  {
    name: "Toad",
    description: "Period-2 oscillator",
    category: "oscillator",
    cells: [
      { row: 2, col: 2 },
      { row: 2, col: 3 },
      { row: 2, col: 4 },
      { row: 3, col: 1 },
      { row: 3, col: 2 },
      { row: 3, col: 3 },
    ],
  },
  {
    name: "Beacon",
    description: "Period-2 oscillator",
    category: "oscillator",
    cells: [
      { row: 1, col: 1 },
      { row: 1, col: 2 },
      { row: 2, col: 1 },
      { row: 2, col: 2 },
      { row: 3, col: 3 },
      { row: 3, col: 4 },
      { row: 4, col: 3 },
      { row: 4, col: 4 },
    ],
  },
  {
    name: "Pulsar",
    description: "Period-3 oscillator - one of the most beautiful",
    category: "oscillator",
    cells: [
      // Top
      { row: 2, col: 4 },
      { row: 2, col: 5 },
      { row: 2, col: 6 },
      { row: 2, col: 10 },
      { row: 2, col: 11 },
      { row: 2, col: 12 },
      // Upper sides
      { row: 4, col: 2 },
      { row: 4, col: 7 },
      { row: 4, col: 9 },
      { row: 4, col: 14 },
      { row: 5, col: 2 },
      { row: 5, col: 7 },
      { row: 5, col: 9 },
      { row: 5, col: 14 },
      { row: 6, col: 2 },
      { row: 6, col: 7 },
      { row: 6, col: 9 },
      { row: 6, col: 14 },
      // Middle
      { row: 7, col: 4 },
      { row: 7, col: 5 },
      { row: 7, col: 6 },
      { row: 7, col: 10 },
      { row: 7, col: 11 },
      { row: 7, col: 12 },
      { row: 9, col: 4 },
      { row: 9, col: 5 },
      { row: 9, col: 6 },
      { row: 9, col: 10 },
      { row: 9, col: 11 },
      { row: 9, col: 12 },
      // Lower sides
      { row: 10, col: 2 },
      { row: 10, col: 7 },
      { row: 10, col: 9 },
      { row: 10, col: 14 },
      { row: 11, col: 2 },
      { row: 11, col: 7 },
      { row: 11, col: 9 },
      { row: 11, col: 14 },
      { row: 12, col: 2 },
      { row: 12, col: 7 },
      { row: 12, col: 9 },
      { row: 12, col: 14 },
      // Bottom
      { row: 14, col: 4 },
      { row: 14, col: 5 },
      { row: 14, col: 6 },
      { row: 14, col: 10 },
      { row: 14, col: 11 },
      { row: 14, col: 12 },
    ],
  },

  // Spaceships
  {
    name: "Glider",
    description: "The smallest spaceship - moves diagonally",
    category: "spaceship",
    cells: [
      { row: 1, col: 2 },
      { row: 2, col: 3 },
      { row: 3, col: 1 },
      { row: 3, col: 2 },
      { row: 3, col: 3 },
    ],
  },
  {
    name: "Lightweight Spaceship (LWSS)",
    description: "Travels horizontally",
    category: "spaceship",
    cells: [
      { row: 1, col: 2 },
      { row: 1, col: 5 },
      { row: 2, col: 1 },
      { row: 3, col: 1 },
      { row: 3, col: 5 },
      { row: 4, col: 1 },
      { row: 4, col: 2 },
      { row: 4, col: 3 },
      { row: 4, col: 4 },
    ],
  },

  // Methuselahs (patterns that evolve for a long time)
  {
    name: "R-pentomino",
    description: "Evolves for 1103 generations before stabilizing",
    category: "methuselah",
    cells: [
      { row: 1, col: 2 },
      { row: 1, col: 3 },
      { row: 2, col: 1 },
      { row: 2, col: 2 },
      { row: 3, col: 2 },
    ],
  },
  {
    name: "Diehard",
    description: "Dies completely after 130 generations",
    category: "methuselah",
    cells: [
      { row: 1, col: 7 },
      { row: 2, col: 1 },
      { row: 2, col: 2 },
      { row: 3, col: 2 },
      { row: 3, col: 6 },
      { row: 3, col: 7 },
      { row: 3, col: 8 },
    ],
  },
  {
    name: "Acorn",
    description: "Evolves for 5206 generations",
    category: "methuselah",
    cells: [
      { row: 1, col: 2 },
      { row: 2, col: 4 },
      { row: 3, col: 1 },
      { row: 3, col: 2 },
      { row: 3, col: 5 },
      { row: 3, col: 6 },
      { row: 3, col: 7 },
    ],
  },
];

// Get patterns by category
export function getPatternsByCategory(category: Pattern["category"]) {
  return PATTERNS.filter((p) => p.category === category);
}

// Offset pattern to center it on the grid
export function centerPattern(pattern: Cell[], gridWidth: number, gridHeight: number): Cell[] {
  if (pattern.length === 0) return [];

  const minRow = Math.min(...pattern.map((c) => c.row));
  const maxRow = Math.max(...pattern.map((c) => c.row));
  const minCol = Math.min(...pattern.map((c) => c.col));
  const maxCol = Math.max(...pattern.map((c) => c.col));

  const patternWidth = maxCol - minCol + 1;
  const patternHeight = maxRow - minRow + 1;

  const offsetRow = Math.floor((gridHeight - patternHeight) / 2) - minRow;
  const offsetCol = Math.floor((gridWidth - patternWidth) / 2) - minCol;

  return pattern.map((cell) => ({
    row: cell.row + offsetRow,
    col: cell.col + offsetCol,
  }));
}
