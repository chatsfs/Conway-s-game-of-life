class GameError < StandardError
  attr_reader :code

  def initialize(message, code = :game_error)
    @code = code
    super(message)
  end
end

class GameTimeoutError < GameError
  def initialize(max_generations)
    super("Board doesn't reach conclusion after #{max_generations} attempts", :timeout)
  end
end

class InvalidCellPositionError < GameError
  def initialize(row, col, height, width)
    super("Cell position (#{row}, #{col}) is out of bounds for #{height}x#{width} grid", :invalid_position)
  end
end

class InvalidParameterError < GameError
  def initialize(param_name, message = nil)
    msg = message || "Invalid parameter: #{param_name}"
    super(msg, :invalid_parameter)
  end
end
