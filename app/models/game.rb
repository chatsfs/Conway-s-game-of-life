class Game < ApplicationRecord
  validates :width, :height, presence: true, numericality: { greater_than: 0 }

  attribute :cells, :json, default: -> { [] }
  attribute :initial_cells, :json, default: -> { [] }
  attribute :history, :json, default: -> { [] }

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
    save_to_history
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

  def randomize(density:)
    self.cells = Array.new(height) do |row|
      Array.new(width) do |col|
        rand < density
      end
    end
    @cell_grid = nil
    save! if persisted?
  end

  def clear!
    self.cells = Array.new(height) { Array.new(width, false) }
    self.generation = 0
    @cell_grid = nil
    save! if persisted?
  end

  def reset_to_initial!
    self.cells = initial_cells.deep_dup
    self.generation = 0
    @cell_grid = nil
    save! if persisted?
  end

  def to_grid
    cell_grid.map(&:dup)
  end

  def alive_cells
    cells_list = []
    (0...height).each do |row|
      (0...width).each do |col|
        if alive_at?(row, col)
          cells_list << { row: row, col: col }
        end
      end
    end
    cells_list
  end

  def to_rle
    result = ""
    (0...height).each do |row|
      count = 1
      current = alive_at?(row, 0)

      (1...width).each do |col|
        cell = alive_at?(row, col)
        if cell == current
          count += 1
        else
          result += count > 1 ? "#{count}#{current ? 'o' : 'b'}" : (current ? "o" : "b")
          current = cell
          count = 1
        end
      end

      result += count > 1 ? "#{count}#{current ? 'o' : 'b'}" : (current ? "o" : "b")
      result += "$" unless row == height - 1
    end

    result + "!"
  end

  def pattern_bounds
    alive_positions = alive_cells
    return nil if alive_positions.empty?

    rows = alive_positions.map { |pos| pos[:row] }
    cols = alive_positions.map { |pos| pos[:col] }

    min_row = rows.min
    max_row = rows.max
    min_col = cols.min
    max_col = cols.max

    {
      min_row: min_row,
      max_row: max_row,
      min_col: min_col,
      max_col: max_col,
      width: max_col - min_col + 1,
      height: max_row - min_row + 1
    }
  end

  def count_neighbors_at(row, col)
    count_neighbors(row, col)
  end

  def stable?
    return false if generation == 0
    return false if history.empty?

    current_state = cells.to_s
    history.last == current_state
  end

  def extinct?
    population == 0
  end

  def oscillating?
    return false if generation < 2
    return false if history.length < 2

    current_state = cells.to_s
    history.each_with_index do |past_state, index|
      if past_state == current_state
        return true
      end
    end
    false
  end

  def oscillation_period
    return nil unless oscillating?

    current_state = cells.to_s
    history.reverse.each_with_index do |past_state, index|
      if past_state == current_state
        return index + 1
      end
    end
    nil
  end

  def advance_and_get_changes
    old_alive = alive_cells
    advance_generation
    new_alive = alive_cells

    born = new_alive - old_alive
    died = old_alive - new_alive

    { born: born, died: died }
  end

  private

  def setup_cells
    return if persisted? && cells.present?
    empty_grid = Array.new(height || 0) { Array.new(width || 0, false) }
    self.cells = empty_grid
    self.initial_cells = empty_grid.deep_dup
    self.history = []
  end

  def save_to_history
    current_state = cells.to_s
    self.history = (history || []) << current_state
    self.history = history.last(10) if history.length > 10
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
