require 'rails_helper'

RSpec.describe 'Games API' do
  describe 'POST /games' do
    let(:valid_params) { { width: 10, height: 10 } }

    it 'creates a new game' do
      post '/games', params: valid_params

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to include(
        'width' => 10,
        'height' => 10,
        'generation' => 0,
        'population' => 0
      )
    end

    it 'requires width parameter' do
      post '/games', params: { height: 10 }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'requires height parameter' do
      post '/games', params: { width: 10 }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'GET /games/:id' do
    let(:game_data) { { width: 5, height: 5 } }

    it 'returns game state' do
      post '/games', params: game_data
      game_id = JSON.parse(response.body)['id']

      get "/games/#{game_id}"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include(
        'id' => game_id,
        'generation' => 0,
        'population' => 0
      )
    end

    it 'returns 404 for non-existent game' do
      get '/games/999'

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /games/:id/advance' do
    let(:game_data) { { width: 5, height: 5 } }

    it 'advances game generation' do
      post '/games', params: game_data
      game_id = JSON.parse(response.body)['id']

      post "/games/#{game_id}/advance"

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['generation']).to eq(1)
    end
  end

  describe 'PUT /games/:id/cells' do
    let(:game_data) { { width: 5, height: 5 } }

    it 'sets cells alive' do
      post '/games', params: game_data
      game_id = JSON.parse(response.body)['id']

      put "/games/#{game_id}/cells", params: {
        cells: [
          { row: 1, col: 2 },
          { row: 2, col: 2 },
          { row: 3, col: 2 }
        ]
      }

      expect(response).to have_http_status(:ok)

      game_response = JSON.parse(response.body)
      expect(game_response['population']).to eq(3)
    end

    it 'validates cell coordinates are in bounds' do
      post '/games', params: game_data
      game_id = JSON.parse(response.body)['id']

      put "/games/#{game_id}/cells", params: {
        cells: [ { row: 10, col: 10 } ]
      }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /games/:id' do
    let(:game_data) { { width: 5, height: 5 } }

    it 'deletes the game' do
      post '/games', params: game_data
      game_id = JSON.parse(response.body)['id']

      delete "/games/#{game_id}"

      expect(response).to have_http_status(:no_content)

      get "/games/#{game_id}"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /games/:id/randomize' do
    let(:game_data) { { width: 10, height: 10 } }

    it 'randomizes grid with density' do
      post '/games', params: game_data
      game_id = JSON.parse(response.body)['id']

      post "/games/#{game_id}/randomize", params: { density: 0.3 }

      expect(response).to have_http_status(:ok)

      game_response = JSON.parse(response.body)
      expect(game_response['population']).to be > 0
      expect(game_response['population']).to be < 100
    end
  end

  describe 'POST /games/:id/reset' do
    let(:game_data) { { width: 5, height: 5 } }

    it 'resets game to initial state' do
      post '/games', params: game_data
      game_id = JSON.parse(response.body)['id']

      put "/games/#{game_id}/cells", params: {
        cells: [ { row: 1, col: 1 } ]
      }
      post "/games/#{game_id}/advance"

      post "/games/#{game_id}/reset"

      expect(response).to have_http_status(:ok)
      game_response = JSON.parse(response.body)
      expect(game_response['generation']).to eq(0)
    end
  end

  describe 'GET /games/:id/analysis' do
    let(:game_data) { { width: 4, height: 4 } }

    it 'returns analysis data' do
      post '/games', params: game_data
      game_id = JSON.parse(response.body)['id']

      put "/games/#{game_id}/cells", params: {
        cells: [
          { row: 1, col: 1 },
          { row: 1, col: 2 },
          { row: 2, col: 1 },
          { row: 2, col: 2 }
        ]
      }

      get "/games/#{game_id}/analysis"

      expect(response).to have_http_status(:ok)
      analysis = JSON.parse(response.body)

      expect(analysis).to include(
        'population' => 4,
        'stable' => false,
        'extinct' => false,
        'oscillating' => false,
        'bounds' => {
          'min_row' => 1,
          'max_row' => 2,
          'min_col' => 1,
          'max_col' => 2,
          'width' => 2,
          'height' => 2
        }
      )
    end
  end

  describe 'GET /games/:id/export' do
    let(:game_data) { { width: 3, height: 3 } }

    it 'exports grid in multiple formats' do
      post '/games', params: game_data
      game_id = JSON.parse(response.body)['id']

      put "/games/#{game_id}/cells", params: {
        cells: [ { row: 1, col: 1 } ]
      }

      get "/games/#{game_id}/export"

      expect(response).to have_http_status(:ok)
      export_data = JSON.parse(response.body)

      expect(export_data).to include('grid', 'rle', 'alive_cells')
      expect(export_data['alive_cells']).to contain_exactly(
        { 'row' => 1, 'col' => 1 }
      )
    end
  end

  describe 'POST /games/:id/next' do
    let(:game_data) { { width: 3, height: 3 } }

    it 'returns next state without advancing the game' do
      post '/games', params: game_data
      game_id = JSON.parse(response.body)['id']

      put "/games/#{game_id}/cells", params: {
        cells: [
          { row: 0, col: 1 },
          { row: 1, col: 1 },
          { row: 2, col: 1 }
        ]
      }

      post "/games/#{game_id}/next"

      expect(response).to have_http_status(:ok)
      next_state = JSON.parse(response.body)
      
      expect(next_state).to include('grid', 'generation', 'population')
      expect(next_state['generation']).to eq(1)

      get "/games/#{game_id}"
      current_game = JSON.parse(response.body)
      expect(current_game['generation']).to eq(0)
    end
  end

  describe 'POST /games/:id/advance_states' do
    let(:game_data) { { width: 5, height: 5 } }

    it 'advances game by specified number of generations' do
      post '/games', params: game_data
      game_id = JSON.parse(response.body)['id']

      put "/games/#{game_id}/cells", params: {
        cells: [
          { row: 1, col: 2 },
          { row: 2, col: 2 },
          { row: 3, col: 2 }
        ]
      }

      post "/games/#{game_id}/advance_states", params: { states: 3 }

      expect(response).to have_http_status(:ok)
      result = JSON.parse(response.body)
      
      expect(result['generation']).to eq(3)
      expect(result).to include('id', 'width', 'height', 'population')
    end

    it 'requires states parameter' do
      post '/games', params: game_data
      game_id = JSON.parse(response.body)['id']

      post "/games/#{game_id}/advance_states"

      expect(response).to have_http_status(:unprocessable_content)
      error = JSON.parse(response.body)
      expect(error['error']).to include('States parameter is required')
    end

    it 'validates states is a positive integer' do
      post '/games', params: game_data
      game_id = JSON.parse(response.body)['id']

      post "/games/#{game_id}/advance_states", params: { states: -1 }

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'POST /games/:id/final_state' do
    let(:game_data) { { width: 5, height: 5 } }

    it 'returns final stable state' do
      post '/games', params: game_data
      game_id = JSON.parse(response.body)['id']

      put "/games/#{game_id}/cells", params: {
        cells: [
          { row: 1, col: 1 },
          { row: 1, col: 2 },
          { row: 2, col: 1 },
          { row: 2, col: 2 }
        ]
      }

      post "/games/#{game_id}/final_state"

      expect(response).to have_http_status(:ok)
      result = JSON.parse(response.body)
      
      expect(result).to include('final_generation', 'reason', 'population')
      expect(result['reason']).to eq('stable')
    end

    it 'returns error when no conclusion reached within max attempts' do
      post '/games', params: { width: 10, height: 10 }
      game_id = JSON.parse(response.body)['id']

      post "/games/#{game_id}/randomize", params: { density: 0.4 }

      post "/games/#{game_id}/final_state", params: { max_generations: 1 }

      expect(response).to have_http_status(:unprocessable_content)
      error = JSON.parse(response.body)
      expect(error['error']).to include('conclusion')
    end

    it 'detects extinction' do
      post '/games', params: game_data
      game_id = JSON.parse(response.body)['id']

      put "/games/#{game_id}/cells", params: {
        cells: [ { row: 1, col: 1 } ]
      }

      post "/games/#{game_id}/final_state"

      expect(response).to have_http_status(:ok)
      result = JSON.parse(response.body)
      
      expect(result['reason']).to eq('extinct')
      expect(result['population']).to eq(0)
    end
  end
end
