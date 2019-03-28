Rails.application.routes.draw do
  
  # admin-only routes
  authenticate :user, -> (u) { u.admin? } do
    get 'admin/index'
    resources :admin
    # routes for agent csv imports
    get 'agents/index'
    get 'agents/import'
    resources :agents do
      collection { post :import}
    end

    # routes for date csv imports
    get 'date_values/index'
    get 'date_values/import'
    resources :date_values do
      collection { post :import}
    end
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
  resources :calendars

  # routes for pto_requests
  post "pto_requests/:id/excuse_request" => 'pto_requests#excuse_request', as: :excuse_pto_request
  
  resources :pto_requests do
    post :add_request_for_user, as: :admin_pto_request
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
