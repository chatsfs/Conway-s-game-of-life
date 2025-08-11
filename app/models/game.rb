class Game < ApplicationRecord
  validates :width, :height, presence: true, numericality: { greater_than: 0 }
  
  attribute :cells, :json, default: -> { [] }

  after_initialize :setup_cells

  def alive_at?(row, col)
    return false if out_of_bounds?(row, col)
    cell_grid[row][col]
  end

  def set_alive(row, col)
    return if out_of_bounds?(row, col)
    grid = cell_grid.map(&:dup)
    grid[row][col] = true
    self.cells = grid
    @cell_grid = nil
  end

  def advance_generation
    new_cells = Array.new(height) { Array.new(width, false) }

    (0...height).each do |row|
      (0...width).each do |col|
        alive = cell_grid[row][col]
        neighbors = count_neighbors(row, col)
        new_cells[row][col] = CellRules.next_state(alive, neighbors)
      end
    end

    self.cells = new_cells
    self.generation += 1
    @cell_grid = nil
  end

  def advance_generation!
    advance_generation
    save!
  end

  def population
    cell_grid.sum { |row| row.count(true) }
  end

  def set_cells(cell_positions)
    cell_positions.each do |pos|
      set_alive(pos[:row].to_i, pos[:col].to_i)
    end
    save!
  end

  private

  def setup_cells
    return if persisted? && cells.present?
    self.cells = Array.new(height || 0) { Array.new(width || 0, false) }
  end

  def cell_grid
    @cell_grid ||= cells || Array.new(height) { Array.new(width, false) }
  end

  def count_neighbors(row, col)
    count = 0
    (-1..1).each do |dr|
      (-1..1).each do |dc|
        next if dr == 0 && dc == 0
        count += 1 if alive_at?(row + dr, col + dc)
      end
    end
    count
  end

  def out_of_bounds?(row, col)
    row < 0 || row >= height || col < 0 || col >= width
  end
end
