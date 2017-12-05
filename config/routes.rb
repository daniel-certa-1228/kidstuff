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
end
