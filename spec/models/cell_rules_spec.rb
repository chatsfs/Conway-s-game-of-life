require 'rails_helper'

RSpec.describe CellRules do
  describe '.next_state' do
    context 'when cell is alive' do
      it 'dies with 0 neighbors' do
        expect(CellRules.next_state(true, 0)).to eq(false)
      end

      it 'dies with 1 neighbor' do
        expect(CellRules.next_state(true, 1)).to eq(false)
      end

      it 'survives with 2 neighbors' do
        expect(CellRules.next_state(true, 2)).to eq(true)
      end

      it 'survives with 3 neighbors' do
        expect(CellRules.next_state(true, 3)).to eq(true)
      end

      it 'dies with 4 neighbors' do
        expect(CellRules.next_state(true, 4)).to eq(false)
      end

      it 'dies with 8 neighbors' do
        expect(CellRules.next_state(true, 8)).to eq(false)
      end
    end

    context 'when cell is dead' do
      it 'stays dead with 0 neighbors' do
        expect(CellRules.next_state(false, 0)).to eq(false)
      end

      it 'stays dead with 2 neighbors' do
        expect(CellRules.next_state(false, 2)).to eq(false)
      end

      it 'becomes alive with exactly 3 neighbors' do
        expect(CellRules.next_state(false, 3)).to eq(true)
      end

      it 'stays dead with 4 neighbors' do
        expect(CellRules.next_state(false, 4)).to eq(false)
      end
    end
  end
end
