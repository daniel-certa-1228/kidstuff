Rails.application.routes.draw do
  resources :children
  resources :users
  resources :activities
  resources :assignments
  resources :artworks
  resources :sessions
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'home/index'
  root 'home#index'
  get 'signup', to: 'users#new', as: 'signup'
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
end
