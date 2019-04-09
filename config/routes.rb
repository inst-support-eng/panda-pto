Rails.application.routes.draw do
  
  # admin-only routes
  authenticate :user, -> (u) { u.admin? } do
    get 'admin/index'
    get 'admin/coverage'
    resources :admin
    # routes for agent csv imports
    get 'agents/index'
    get 'agents/import'
    resources :agents do
      collection { post :import}
    end
    get 'pto_requests/export'
    # routes for date csv imports
    get 'date_values/index'
    get 'date_values/import'
    resources :date_values do
      collection { post :import}
    end

    post 'calendars/import', to: 'calendars#import'
  end
  # note: this redirects to 'users/sign_in', not '/login'
  # same thing, just not using the alias
  # end admin-only
  
  devise_for :users, :controllers => {:registrations => "registrations"}
  devise_scope :user do 
    get 'login' => 'devise/sessions#new'
    get 'users/sign_out' => 'devise/sessions#destroy'
    get 'forgot_password' => 'devise/passwords#new'
  end

  # routes for calendar methods
  get 'calendars/fetch_dates', to: 'calendars#fetch_dates'

  # routes for refactored date csv imports
  resources :calendars do
    collection { post :import}
end
  # routes for pto_requests
  post "pto_requests/:id/excuse_request" => 'pto_requests#excuse_request', as: :excuse_pto_request
  get 'pto_requests/import'
  resources :pto_requests do
    collection { post :import_request}
  end
  
  # routes for users 
  get 'current' => 'users#current'
  get 'users/:id' => 'users#show', as: :show_user
  
  resources :users  do
    put :update_shift
    post :update_admin
    post :send_password_reset
    post :add_request_for_user
  end
  root to: 'pages#index'
end
