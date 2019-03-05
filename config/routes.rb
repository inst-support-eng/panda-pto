Rails.application.routes.draw do
  
  # routes for agent csv imports
  get 'agents/index'
  get 'agents/import'
  resources :agents do
  	collection { post :import}
  end

  # routes for calendar methods
  get 'calendars/fetch_dates', to: 'calendars#fetch_dates'
  resources :calendars

  # routes for pto_requests
  resources :pto_requests

  # routes for date csv imports
  get 'date_values/index'
  get 'date_values/import'
  resources :date_values do
  	collection { post :import}
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  devise_for :users, :controllers => {:registrations => "registrations"}
  devise_scope :user do 
    get 'login', to: 'devise/sessions#new'
    get '/users/sign_out' => 'devise/sessions#destroy'
    get 'forgot_password', to: 'devise/passwords#new'
  end

  # routes for users 
  get '/current', to: 'users#current'
  
  resources :users  do
    put :update_shift
  end
  
  root to: 'pages#index'
end
