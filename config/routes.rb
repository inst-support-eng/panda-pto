Rails.application.routes.draw do
  
  # !TECHDEBT need to create new role-specific routing
  # sup routes
  get 'sup/index'
  get 'sup/coverage'
  resources :sup
  # legacy redirect lolololol
  get 'admin/coverage' => 'sup#coverage'

  # admin-only routes
  authenticate :user, -> (u) { u.admin? || u.position == "Sup"} do
    get 'admin/index'
    resources :admin
    # routes for agent csv imports
    get 'agents/index'
    get 'agents/import'
    resources :agents do
      collection { post :import}
    end

    get 'pto_requests/export'
    get 'pto_requests/export_user_request/:id' => 'pto_requests#export_user_request', as: 'export_user_request'
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
  post 'calendars/import' => 'calendars#import'
  post 'calendars/update_base_price' => 'calendars#update_base_price', as: 'update_base_price'

  get 'calendars/fetch_dates' => 'calendars#fetch_dates'
  get 'calendars/l2_fetch_dates' => 'calendar_l2s#fetch_dates'
  get 'calendars/l3_fetch_dates' => 'calendar_l3s#fetch_dates'
  get 'calendars/sups_fetch_dates' => 'calendar_sups#fetch_dates'

  # routes for refactored date csv imports
  resources :calendars do
    collection { post :import}
  end
  # routes for pto_requests
  post "pto_requests/:id/excuse_request" => 'pto_requests#excuse_request', as: :excuse_pto_request
  post "pto_requests/:id/add_no_call_show" => 'pto_requests#add_no_call_show', as: :add_no_call_show
  post "pto_requests/:id/sub_no_call_show" => 'pto_requests#sub_no_call_show', as: :sub_no_call_show
  get 'pto_requests/import'
  resources :pto_requests do
    collection { post :import_request}
  end
  
  # add feedback route !TECHDEBT
  match "/feedback" => redirect("https://docs.google.com/forms/d/e/1FAIpQLSdxkcvYhkhql5-39tJZE7ERjSOtw2eEfq9j-KynRV08luSAJw/viewform"), :via => [:get], :as => :feedback

  # routes for users 
  get 'current' => 'users#current'
  get 'users/:id' => 'users#show', as: :show_user
  
  resources :users  do
    put :update_shift
    post :update_admin
    post :update_pip
    post :send_password_reset
    post :add_request_for_user
    delete :destroy
  end
  root to: 'pages#index'
end
