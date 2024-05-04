Rails.application.routes.draw do
  root "static_pages#home"
  get "elimination_operation" => "static_pages#elimination_operation"
  get "roundrobin_operation" => "static_pages#roundrobin_operation"
  get "inquiry" => "static_pages#inquiry"

  resources :eliminations, except: :index do
    resource :draw, only: [:show], module: :eliminations
    resource :authentication, only: [:new, :create], module: :eliminations
    post :reset, on: :member
    get :share, on: :member
  end
  get 'index_eliminations' => 'eliminations#index'

  resources :roundrobins, except: :index do
    resource :draw, only: [:show, :update], module: :roundrobins
    resource :ranking, only: [:show], module: :roundrobins
    resource :authentication, only: [:new, :create], module: :roundrobins
    post :reset, on: :member
    get :share, on: :member
  end
  get 'index_roundrobins' => 'roundrobins#index'

  resources :tournaments, only: [:index] do
    namespace :teams do
      resource :shuffle, only: [:create]
      resource :bulk_update, only: [:create]
    end
    resources :teams, except: :show
    resources :games
    resource :bookmark, only: [:create, :destroy]
  end
end
