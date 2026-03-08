Rails.application.routes.draw do
  resources :sessions
  resources :identities
  # resources :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  scope :auth do 
    post 'signup', to: 'auth#signup'
    post 'login', to: 'auth#login'
    delete 'logout', to: 'auth#logout'
    post 'refresh', to: 'sessions#refresh'
  end

  resources :conversations, only: [:create, :index, :show] do
    resources :messages, only: [:create, :index]
  end

  resources :discoveries, only: [] do 
    collection do 
      post :search_creators
    end
  end

  resources :media, only: [] do
    collection do
      get :signature       
      post :confirm_upload 
    end
  end

  resources :campaigns do
    member do
      get :matches
      post :invite
      post :onboard
    end
  end

  resources :deliverables, only: [:create] do
    member do
      patch :submit
      patch :approve
      patch :reject
    end
  end

  scope :users do 
    get 'me', to: 'users#me'
    get 'deliverables', to: 'users#deliverables'
  end
end
