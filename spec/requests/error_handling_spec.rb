require 'rails_helper'

RSpec.describe 'Error Handling' do
  describe 'Resource not found' do
    it 'returns structured error for non-existent game' do
      get '/games/999999'
      
      expect(response).to have_http_status(:not_found)
      
      error_response = JSON.parse(response.body)
      expect(error_response).to have_key('error')
      expect(error_response['error']).to include(
        'message' => 'Resource not found',
        'code' => 'not_found'
      )
      expect(error_response['error']).to have_key('timestamp')
    end
  end

  describe 'Validation errors' do
    it 'returns structured error for invalid game creation' do
      post '/games', params: { width: -1, height: 0 }
      
      expect(response).to have_http_status(:unprocessable_content)
      
      error_response = JSON.parse(response.body)
      expect(error_response).to have_key('error')
      expect(error_response['error']).to include(
        'message' => 'Validation failed',
        'code' => 'unprocessable_content'
      )
      expect(error_response['error']).to have_key('timestamp')
      expect(error_response['error']['details']).to be_an(Array)
    end
  end

  describe 'Parameter errors' do
    let(:game_data) { { width: 10, height: 10 } }
    let(:game_id) do
      post '/games', params: game_data
      JSON.parse(response.body)['id']
    end

    it 'returns error for invalid cell positions' do
      put "/games/#{game_id}/cells", params: {
        cells: [ { row: 20, col: 20 } ]
      }
      
      expect(response).to have_http_status(:unprocessable_content)
      
      error_response = JSON.parse(response.body)
      expect(error_response['error']['message']).to include('out of bounds')
      expect(error_response['error']['code']).to eq('unprocessable_content')
    end

    it 'returns error for invalid density parameter' do
      post "/games/#{game_id}/randomize", params: { density: 2.0 }
      
      expect(response).to have_http_status(:unprocessable_content)
      
      error_response = JSON.parse(response.body)
      expect(error_response['error']['message']).to include('Density must be between 0 and 1')
    end

    it 'returns error for missing states parameter' do
      post "/games/#{game_id}/advance_states"
      
      expect(response).to have_http_status(:unprocessable_content)
      
      error_response = JSON.parse(response.body)
      expect(error_response['error']['message']).to include('States parameter is required')
    end

    it 'returns error for invalid states value' do
      post "/games/#{game_id}/advance_states", params: { states: 20000 }
      
      expect(response).to have_http_status(:unprocessable_content)
      
      error_response = JSON.parse(response.body)
      expect(error_response['error']['message']).to include('States must be between 1 and 10000')
    end

    it 'returns error for negative states value' do
      post "/games/#{game_id}/advance_states", params: { states: -5 }
      
      expect(response).to have_http_status(:unprocessable_content)
      
      error_response = JSON.parse(response.body)
      expect(error_response['error']['message']).to include('States must be between 1 and 10000')
    end
  end

  describe 'Timeout errors' do
    let(:game_data) { { width: 10, height: 10 } }
    let(:game_id) do
      post '/games', params: game_data
      game_id = JSON.parse(response.body)['id']
      
      post "/games/#{game_id}/randomize", params: { density: 0.4 }
      game_id
    end

    it 'returns timeout error when final state cannot be determined' do
      post "/games/#{game_id}/final_state", params: { max_generations: 1 }
      
      expect(response).to have_http_status(:request_timeout)
      
      error_response = JSON.parse(response.body)
      expect(error_response['error']['message']).to include("doesn't reach conclusion")
      expect(error_response['error']['code']).to eq('request_timeout')
    end

    it 'validates max_generations parameter' do
      post "/games/#{game_id}/final_state", params: { max_generations: 20000 }
      
      expect(response).to have_http_status(:unprocessable_content)
      
      error_response = JSON.parse(response.body)
      expect(error_response['error']['message']).to include('Max generations must be between 1 and 10000')
    end
  end

  describe 'Invalid input formats' do
    let(:game_data) { { width: 5, height: 5 } }
    let(:game_id) do
      post '/games', params: game_data
      JSON.parse(response.body)['id']
    end

    it 'returns error when cells is not an array' do
      put "/games/#{game_id}/cells", params: {
        cells: "not an array"
      }
      
      expect(response).to have_http_status(:unprocessable_content)
      
      error_response = JSON.parse(response.body)
      expect(error_response['error']['message']).to include('Cells must be an array')
    end

    it 'returns error for invalid density value' do
      post "/games/#{game_id}/randomize", params: { density: -0.5 }
      
      expect(response).to have_http_status(:unprocessable_content)
      
      error_response = JSON.parse(response.body)
      expect(error_response['error']['message']).to include('Density must be between 0 and 1')
    end
  end
end