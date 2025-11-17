"use client";

import { useEffect, useRef, useState } from "react";
import { Grid } from "@/types/game";

interface GameGridProps {
  grid: Grid;
  width: number;
  height: number;
  onCellClick?: (row: number, col: number) => void;
  highlightCells?: Set<string>;
}

const CELL_SIZE = 12; // pixels per cell
const GRID_COLOR = "#334155"; // slate-700
const ALIVE_COLOR = "#22c55e"; // green-500
const DEAD_COLOR = "#1e293b"; // slate-800
const HIGHLIGHT_COLOR = "#3b82f6"; // blue-500

export function GameGrid({ grid, width, height, onCellClick, highlightCells }: GameGridProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [isDragging, setIsDragging] = useState(false);
  const [dragMode, setDragMode] = useState<"alive" | "dead" | null>(null);

  // Draw the grid
  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    // Clear canvas
    ctx.fillStyle = DEAD_COLOR;
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    // Draw grid lines
    ctx.strokeStyle = GRID_COLOR;
    ctx.lineWidth = 1;

    for (let i = 0; i <= width; i++) {
      ctx.beginPath();
      ctx.moveTo(i * CELL_SIZE, 0);
      ctx.lineTo(i * CELL_SIZE, height * CELL_SIZE);
      ctx.stroke();
    }

    for (let i = 0; i <= height; i++) {
      ctx.beginPath();
      ctx.moveTo(0, i * CELL_SIZE);
      ctx.lineTo(width * CELL_SIZE, i * CELL_SIZE);
      ctx.stroke();
    }

    // Draw cells
    for (let row = 0; row < height; row++) {
      for (let col = 0; col < width; col++) {
        const isAlive = grid[row]?.[col] || false;
        const cellKey = `${row},${col}`;
        const isHighlighted = highlightCells?.has(cellKey);

        if (isAlive || isHighlighted) {
          ctx.fillStyle = isHighlighted ? HIGHLIGHT_COLOR : ALIVE_COLOR;
          ctx.fillRect(col * CELL_SIZE + 1, row * CELL_SIZE + 1, CELL_SIZE - 2, CELL_SIZE - 2);
        }
      }
    }
  }, [grid, width, height, highlightCells]);

  const getCellFromEvent = (e: React.MouseEvent<HTMLCanvasElement>) => {
    const canvas = canvasRef.current;
    if (!canvas) return null;

    const rect = canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    const col = Math.floor(x / CELL_SIZE);
    const row = Math.floor(y / CELL_SIZE);

    if (row >= 0 && row < height && col >= 0 && col < width) {
      return { row, col };
    }
    return null;
  };

  const handleMouseDown = (e: React.MouseEvent<HTMLCanvasElement>) => {
    const cell = getCellFromEvent(e);
    if (!cell || !onCellClick) return;

    setIsDragging(true);
    const isAlive = grid[cell.row]?.[cell.col] || false;
    setDragMode(isAlive ? "dead" : "alive");
    onCellClick(cell.row, cell.col);
  };

  const handleMouseMove = (e: React.MouseEvent<HTMLCanvasElement>) => {
    if (!isDragging || !onCellClick) return;

    const cell = getCellFromEvent(e);
    if (!cell) return;

    const isAlive = grid[cell.row]?.[cell.col] || false;
    const shouldToggle =
      (dragMode === "alive" && !isAlive) || (dragMode === "dead" && isAlive);

    if (shouldToggle) {
      onCellClick(cell.row, cell.col);
    }
  };

  const handleMouseUp = () => {
    setIsDragging(false);
    setDragMode(null);
  };

  const handleMouseLeave = () => {
    setIsDragging(false);
    setDragMode(null);
  };

  return (
    <div className="inline-block overflow-auto rounded-lg border-2 border-slate-700 bg-slate-800 shadow-2xl">
      <canvas
        ref={canvasRef}
        width={width * CELL_SIZE}
        height={height * CELL_SIZE}
        className="cursor-pointer"
        onMouseDown={handleMouseDown}
        onMouseMove={handleMouseMove}
        onMouseUp={handleMouseUp}
        onMouseLeave={handleMouseLeave}
      />
    </div>
  );
}
