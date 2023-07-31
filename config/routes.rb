Rails.application.routes.draw do
  root "static_pages#home"

  resources :eliminations do
    post :reset, on: :member
    get :share, on: :member
  end
  resources :roundrobins do
    get :change_round, on: :member
    post :reset, on: :member
    get :ranking, on: :member
    get :share, on: :member
  end
  resources :tournaments, only: [:index] do
    resources :teams
    resources :games
  end
end
