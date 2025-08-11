class Game
  attr_reader :width, :height, :generation

  def initialize(width:, height:)
    @width = width
    @height = height
    @generation = 0
    @cells = Array.new(height) { Array.new(width, false) }
  end

  def alive_at?(row, col)
    return false if out_of_bounds?(row, col)
    @cells[row][col]
  end

  def set_alive(row, col)
    return if out_of_bounds?(row, col)
    @cells[row][col] = true
  end

  def advance_generation
    new_cells = Array.new(@height) { Array.new(@width, false) }
    
    (0...@height).each do |row|
      (0...@width).each do |col|
        alive = @cells[row][col]
        neighbors = count_neighbors(row, col)
        new_cells[row][col] = CellRules.next_state(alive, neighbors)
      end
    end
    
    @cells = new_cells
    @generation += 1
  end

  def population
    @cells.sum { |row| row.count(true) }
  end

  private

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
    row < 0 || row >= @height || col < 0 || col >= @width
  end
end