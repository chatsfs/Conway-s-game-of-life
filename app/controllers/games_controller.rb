class GamesController < ApplicationController
  before_action :find_game, only: [ :show, :advance, :cells, :destroy, :randomize, :reset, :analysis, :export, :next, :advance_states, :final_state ]

  def create
    game = Game.new(game_params)

    if game.save
      render json: game_json(game), status: :created
    else
      render json: { errors: game.errors.full_messages }, status: :unprocessable_content
    end
  end

  def show
    render json: game_json(@game)
  end

  def advance
    @game.advance_generation!
    render json: game_json(@game)
  end

  def cells
    if valid_cell_positions?
      @game.set_cells(params[:cells])
      render json: game_json(@game)
    else
      render json: { error: "Invalid cell coordinates" }, status: :unprocessable_content
    end
  end

  def destroy
    @game.destroy
    head :no_content
  end

  def randomize
    density = params[:density].to_f
    @game.randomize(density: density)
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
    if params[:states].blank?
      render json: { error: "States parameter is required" }, status: :unprocessable_content
      return
    end

    states = params[:states].to_i

    if states <= 0
      render json: { error: "States parameter must be a positive integer" }, status: :unprocessable_content
      return
    end

    states.times { @game.advance_generation! }
    render json: game_json(@game)
  end

  def final_state
    max_generations = params[:max_generations]&.to_i || 1000
    original_generation = @game.generation
    original_cells = @game.cells.deep_dup
    original_history = @game.history.deep_dup

    max_generations.times do
      @game.advance_generation!

      if @game.stable? || @game.extinct? || @game.oscillating?
        reason = if @game.extinct?
          "extinct"
        elsif @game.stable?
          "stable"
        elsif @game.oscillating?
          "oscillating"
        end

        render json: {
          final_generation: @game.generation,
          reason: reason,
          population: @game.population,
          oscillation_period: @game.oscillation_period
        }
        return
      end
    end

    @game.update(
      generation: original_generation,
      cells: original_cells,
      history: original_history
    )
    render json: {
      error: "Board doesn't reach conclusion after #{max_generations} attempts"
    }, status: :unprocessable_content
  end

  private

  def find_game
    @game = Game.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Game not found" }, status: :not_found
  end

  def game_params
    params.permit(:width, :height)
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

  def valid_cell_positions?
    return false unless params[:cells].is_a?(Array)

    params[:cells].all? do |cell|
      row = cell[:row].to_i
      col = cell[:col].to_i
      row >= 0 && row < @game.height && col >= 0 && col < @game.width
    end
  end
end
