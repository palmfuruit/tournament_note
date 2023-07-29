Rails.application.routes.draw do
  root "static_pages#home"

  resources :eliminations do
    post :reset, on: :member
    get :share, on: :member
  end
  resources :tournaments, only: [:index] do
    resources :teams
    resources :games
  end
end
