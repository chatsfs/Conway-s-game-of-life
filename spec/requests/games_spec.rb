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
        cells: [{ row: 10, col: 10 }]
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
end