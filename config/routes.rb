Rails.application.routes.draw do
  root "static_pages#home"
  get "elimination_operation" => "static_pages#elimination_operation"
  get "roundrobin_operation" => "static_pages#roundrobin_operation"
  get "inquiry" => "static_pages#inquiry"

  resources :eliminations, except: :index do
    post :reset, on: :member
    get :share, on: :member
  end
  get 'index_eliminations' => 'eliminations#index'

  resources :roundrobins, except: :index do
    get :change_round, on: :member
    post :reset, on: :member
    get :ranking, on: :member
    get :share, on: :member
  end
  get 'index_roundrobins' => 'roundrobins#index'

  resources :tournaments, only: [:index] do
    resources :teams
    resources :games
  end
end
