class GamesController < ApplicationController
  before_action :set_game, only: [ :show, :advance, :cells, :destroy, :randomize, :reset, :analysis, :export, :next, :advance_states, :final_state ]

  def create
    game = Game.create!(game_params)
    render json: game_json(game), status: :created
  end

  def show
    render json: game_json(@game)
  end

  def advance
    @game.advance_generation!
    render json: game_json(@game)
  end

  def cells
    validate_cell_positions!
    @game.set_cells(cell_positions_params)
    render json: game_json(@game)
  end

  def destroy
    @game.destroy
    head :no_content
  end

  def randomize
    validate_density!
    @game.randomize(density: randomize_params[:density].to_f)
    render json: game_json(@game)
  end

  def reset
    @game.reset_to_initial!
    render json: game_json(@game)
  end

  def analysis
    render json: {
      population: @game.population,
      generation: @game.generation,
      stable: @game.stable?,
      extinct: @game.extinct?,
      oscillating: @game.oscillating?,
      oscillation_period: @game.oscillation_period,
      bounds: @game.pattern_bounds
    }
  end

  def export
    render json: {
      grid: @game.to_grid,
      rle: @game.to_rle,
      alive_cells: @game.alive_cells
    }
  end

  def next
    game_copy = Game.new(@game.attributes.except("id", "created_at", "updated_at"))
    game_copy.advance_generation

    render json: {
      grid: game_copy.to_grid,
      generation: game_copy.generation,
      population: game_copy.population
    }
  end

  def advance_states
    validate_states_param!
    states = advance_states_params[:states].to_i

    states.times { @game.advance_generation! }
    render json: game_json(@game)
  end

  def final_state
    max_generations = final_state_params[:max_generations]&.to_i || 1000
    validate_max_generations!(max_generations)

    result = @game.find_final_state(max_generations)

    if result[:success]
      render json: {
        final_generation: result[:generation],
        reason: result[:reason],
        population: result[:population],
        oscillation_period: result[:oscillation_period]
      }
    else
      raise GameTimeoutError.new(max_generations)
    end
  end

  private

  def set_game
    @game = Game.find(params[:id])
  end

  def game_params
    params.require(:game).permit(:width, :height)
  rescue ActionController::ParameterMissing
    params.permit(:width, :height)
  end

  def cell_positions_params
    params.require(:cells)
  end

  def randomize_params
    params.permit(:density)
  end

  def advance_states_params
    params.permit(:states)
  end

  def final_state_params
    params.permit(:max_generations)
  end

  def game_json(game)
    {
      id: game.id,
      width: game.width,
      height: game.height,
      generation: game.generation,
      population: game.population
    }
  end

  def validate_cell_positions!
    cells = params[:cells]
    raise InvalidParameterError.new(:cells, "Cells must be an array") unless cells.is_a?(Array)

    cells.each do |cell|
      row = cell[:row].to_i
      col = cell[:col].to_i
      unless row >= 0 && row < @game.height && col >= 0 && col < @game.width
        raise InvalidCellPositionError.new(row, col, @game.height, @game.width)
      end
    end
  end

  def validate_density!
    density = params[:density].to_f
    unless density > 0 && density <= 1
      raise InvalidParameterError.new(:density, "Density must be between 0 and 1")
    end
  end

  def validate_states_param!
    raise InvalidParameterError.new(:states, "States parameter is required") if params[:states].blank?

    states = params[:states].to_i
    unless states > 0 && states <= 10000
      raise InvalidParameterError.new(:states, "States must be between 1 and 10000")
    end
  end

  def validate_max_generations!(max_generations)
    unless max_generations > 0 && max_generations <= 10000
      raise InvalidParameterError.new(:max_generations, "Max generations must be between 1 and 10000")
    end
  end
end
