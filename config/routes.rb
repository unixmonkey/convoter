Rails.application.routes.draw do
  get 'sessions/create'

  get 'sessions/destroy'

  get 'home/show'

  resources :conferences
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
