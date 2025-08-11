class GamesController < ApplicationController
  before_action :find_game, only: [ :show, :advance, :cells, :destroy, :randomize, :reset, :analysis, :export ]

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
