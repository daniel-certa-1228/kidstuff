Rails.application.routes.draw do
  resources :children
  resources :users
  resources :activities do
    collection do
      get :search
    end
  end
  resources :assignments do
    collection do
      get :search
    end
  end
  resources :artworks do
    collection do
      get :search
    end
  end
  resources :sessions
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'home/index'
  root 'home#index'

  get 'signup', to: 'users#new', as: 'signup'
  get 'login', to: 'sessions#new', as: 'login'
  get 'logout', to: 'sessions#destroy', as: 'logout'
#search routing
  get 'artworks/search', to: 'artwork#search', as: 'art_search'
  get 'assignments/search', to: 'assignments#search', as: 'assignment_search'
  get 'activities/search', to: 'activity#search', as: 'activity_search'
#email preview routing
  get 'artworks/send_jpg/:id', to: 'artworks#send_jpg', as: 'send_art'
  get 'assignments/send_jpg/:id', to: 'assignments#send_jpg', as: 'send_assignment'
  get 'activities/send_pdf/:id', to: 'activities#send_jpg', as: 'send_activity'
#mail routing
  post '/artworks/send_jpg/mail_it', to: 'artworks#mail_it', as: 'mail_artwork'
  post '/assignments/send_pdf/mail_it', to: 'assignments#mail_it', as: 'mail_assignment'
  post '/activities/send_pdf/mail_it', to: 'activities#mail_it', as: 'mail_activity'
end
