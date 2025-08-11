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
end
