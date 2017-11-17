Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  get 'auth/:provider/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  get 'signout', to: 'sessions#destroy', as: 'signout'

  resources :sessions, only: [:create, :destroy]
  resources :conferences do
    member do
      get 'set_day(/:day)', to: 'conferences#set_day'
    end
  end
  resources :slots
  resources :votes, only: [:create, :destroy]

  resource :home, only: [:show]

  root to: 'home#show'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
