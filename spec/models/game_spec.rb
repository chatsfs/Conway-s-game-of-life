require 'rails_helper'

RSpec.describe Game do
  describe 'evolution behavior' do
    context 'blinker pattern' do
      let(:game) { Game.new(width: 5, height: 5) }

      before do
        game.set_alive(1, 2)
        game.set_alive(2, 2)
        game.set_alive(3, 2)
      end

      it 'oscillates between vertical and horizontal' do
        game.advance_generation

        expect(game.alive_at?(2, 1)).to eq(true)
        expect(game.alive_at?(2, 2)).to eq(true)
        expect(game.alive_at?(2, 3)).to eq(true)
        expect(game.alive_at?(1, 2)).to eq(false)
        expect(game.alive_at?(3, 2)).to eq(false)

        game.advance_generation

        expect(game.alive_at?(1, 2)).to eq(true)
        expect(game.alive_at?(2, 2)).to eq(true)
        expect(game.alive_at?(3, 2)).to eq(true)
        expect(game.alive_at?(2, 1)).to eq(false)
        expect(game.alive_at?(2, 3)).to eq(false)
      end
    end

    context 'block pattern' do
      let(:game) { Game.new(width: 4, height: 4) }

      before do
        game.set_alive(1, 1)
        game.set_alive(1, 2)
        game.set_alive(2, 1)
        game.set_alive(2, 2)
      end

      it 'remains stable across generations' do
        3.times { game.advance_generation }

        expect(game.alive_at?(1, 1)).to eq(true)
        expect(game.alive_at?(1, 2)).to eq(true)
        expect(game.alive_at?(2, 1)).to eq(true)
        expect(game.alive_at?(2, 2)).to eq(true)
      end
    end

    context 'isolated cell' do
      let(:game) { Game.new(width: 3, height: 3) }

      before do
        game.set_alive(1, 1)
      end

      it 'dies from loneliness' do
        game.advance_generation
        expect(game.alive_at?(1, 1)).to eq(false)
      end
    end

    context 'reproduction' do
      let(:game) { Game.new(width: 3, height: 3) }

      before do
        game.set_alive(0, 1)
        game.set_alive(1, 0)
        game.set_alive(1, 2)
      end

      it 'creates new life with exactly 3 neighbors' do
        game.advance_generation
        expect(game.alive_at?(1, 1)).to eq(true)
      end
    end
  end

  describe 'generation tracking' do
    let(:game) { Game.new(width: 3, height: 3) }

    it 'starts at generation 0' do
      expect(game.generation).to eq(0)
    end

    it 'increments generation on advance' do
      game.advance_generation
      expect(game.generation).to eq(1)

      game.advance_generation
      expect(game.generation).to eq(2)
    end
  end

  describe 'population counting' do
    let(:game) { Game.new(width: 3, height: 3) }

    it 'starts with zero population' do
      expect(game.population).to eq(0)
    end

    it 'counts alive cells' do
      game.set_alive(0, 0)
      game.set_alive(1, 1)
      expect(game.population).to eq(2)
    end
  end

  describe 'boundary handling' do
    let(:game) { Game.new(width: 3, height: 3) }

    it 'returns false for out of bounds coordinates' do
      expect(game.alive_at?(-1, 0)).to eq(false)
      expect(game.alive_at?(3, 0)).to eq(false)
    end

    it 'treats edge cells as having dead neighbors outside bounds' do
      game.set_alive(0, 0)
      game.advance_generation
      expect(game.alive_at?(0, 0)).to eq(false)
    end
  end

  describe 'random initialization' do
    let(:game) { Game.new(width: 10, height: 10) }

    it 'can populate grid randomly' do
      game.randomize(density: 0.3)
      
      expect(game.population).to be > 0
      expect(game.population).to be < 100
    end

    it 'respects density parameter' do
      game.randomize(density: 0.0)
      expect(game.population).to eq(0)
      
      small_game = Game.new(width: 4, height: 4)
      small_game.randomize(density: 1.0)
      expect(small_game.population).to eq(16)
    end

    it 'produces different results on multiple calls' do
      game1 = Game.new(width: 10, height: 10)
      game2 = Game.new(width: 10, height: 10)
      
      game1.randomize(density: 0.5)
      game2.randomize(density: 0.5)
      
      game1_alive = []
      game2_alive = []
      
      (0...10).each do |row|
        (0...10).each do |col|
          game1_alive << [row, col] if game1.alive_at?(row, col)
          game2_alive << [row, col] if game2.alive_at?(row, col)
        end
      end
      
      expect(game1_alive).not_to eq(game2_alive)
    end
  end

  describe 'reset functionality' do
    let(:game) { Game.new(width: 5, height: 5) }

    before do
      game.set_alive(1, 1)
      game.set_alive(2, 2)
      game.advance_generation
      game.advance_generation
    end

    it 'resets to initial state' do
      initial_state = game.to_grid
      
      game.set_alive(3, 3)
      game.advance_generation
      
      game.reset_to_initial!
      
      expect(game.to_grid).to eq(initial_state)
      expect(game.generation).to eq(0)
    end

    it 'clears grid completely' do
      game.clear!
      
      expect(game.population).to eq(0)
      expect(game.generation).to eq(0)
    end
  end

  describe 'grid export' do
    let(:game) { Game.new(width: 3, height: 3) }

    before do
      game.set_alive(0, 1)
      game.set_alive(1, 1)
      game.set_alive(2, 1)
    end

    it 'exports grid as 2D array' do
      expected = [
        [false, true, false],
        [false, true, false],
        [false, true, false]
      ]
      
      expect(game.to_grid).to eq(expected)
    end

    it 'exports alive cell coordinates' do
      alive_cells = game.alive_cells
      
      expect(alive_cells).to contain_exactly(
        { row: 0, col: 1 },
        { row: 1, col: 1 },
        { row: 2, col: 1 }
      )
    end

    it 'exports to RLE format' do
      rle = game.to_rle
      
      expect(rle).to include('b')
      expect(rle).to include('o')
      expect(rle).to end_with('!')
    end
  end

  describe 'pattern bounds analysis' do
    let(:game) { Game.new(width: 10, height: 10) }

    before do
      game.set_alive(2, 3)
      game.set_alive(4, 7)
      game.set_alive(6, 1)
    end

    it 'calculates bounding box of alive cells' do
      bounds = game.pattern_bounds
      
      expect(bounds).to eq({
        min_row: 2,
        max_row: 6,
        min_col: 1,
        max_col: 7,
        width: 7,
        height: 5
      })
    end

    it 'returns nil bounds when no alive cells' do
      empty_game = Game.new(width: 5, height: 5)
      expect(empty_game.pattern_bounds).to be_nil
    end
  end

  describe 'stability detection' do
    context 'still life detection' do
      let(:game) { Game.new(width: 4, height: 4) }
      
      before do
        game.set_alive(1, 1)
        game.set_alive(1, 2)
        game.set_alive(2, 1)
        game.set_alive(2, 2)
      end

      it 'detects when pattern is stable' do
        expect(game.stable?).to eq(false)
        
        game.advance_generation
        expect(game.stable?).to eq(true)
      end
    end

    context 'oscillator detection' do
      let(:game) { Game.new(width: 5, height: 5) }
      
      before do
        game.set_alive(1, 2)
        game.set_alive(2, 2)
        game.set_alive(3, 2)
      end

      it 'detects oscillating pattern' do
        expect(game.oscillating?).to eq(false)
        
        game.advance_generation
        expect(game.oscillating?).to eq(false)
        
        game.advance_generation
        expect(game.oscillating?).to eq(true)
        expect(game.oscillation_period).to eq(2)
      end
    end

    context 'extinction detection' do
      let(:game) { Game.new(width: 3, height: 3) }
      
      before do
        game.set_alive(1, 1)
      end

      it 'detects when pattern dies out' do
        expect(game.extinct?).to eq(false)
        
        game.advance_generation
        expect(game.extinct?).to eq(true)
      end
    end
  end

  describe 'neighbor counting' do
    let(:game) { Game.new(width: 5, height: 5) }

    before do
      game.set_alive(1, 1)
      game.set_alive(1, 2)
      game.set_alive(2, 3)
    end

    it 'counts neighbors for any cell' do
      expect(game.count_neighbors_at(2, 2)).to eq(3)
      expect(game.count_neighbors_at(0, 0)).to eq(1)
      expect(game.count_neighbors_at(4, 4)).to eq(0)
    end

    it 'handles boundary cells correctly' do
      expect(game.count_neighbors_at(0, 1)).to eq(2)
    end
  end

  describe 'difference detection' do
    let(:game) { Game.new(width: 5, height: 5) }

    before do
      game.set_alive(1, 2)
      game.set_alive(2, 2)
      game.set_alive(3, 2)
    end

    it 'detects changes between generations' do
      changes = game.advance_and_get_changes
      
      expect(changes[:born]).to contain_exactly(
        { row: 2, col: 1 },
        { row: 2, col: 3 }
      )
      expect(changes[:died]).to contain_exactly(
        { row: 1, col: 2 },
        { row: 3, col: 2 }
      )
    end

    it 'returns empty changes when stable' do
      block_game = Game.new(width: 4, height: 4)
      block_game.set_alive(1, 1)
      block_game.set_alive(1, 2)
      block_game.set_alive(2, 1)
      block_game.set_alive(2, 2)
      
      changes = block_game.advance_and_get_changes
      
      expect(changes[:born]).to be_empty
      expect(changes[:died]).to be_empty
    end
  end
end
