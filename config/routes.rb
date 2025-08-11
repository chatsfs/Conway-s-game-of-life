Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :games, only: [:create, :show, :destroy] do
    member do
      post :advance
      put :cells
      post :randomize
      post :reset
      get :analysis
      get :export
    end
  end
end
