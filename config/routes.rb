Rails.application.routes.draw do

  authenticate :user, -> (u) { u.admin? } do
    get 'pto_requests/export' => 'pto_requests#export'
  end
    resources :pto_requests do
      collection { post :create}
    end
    # user routes
    devise_for :users, :controllers => {:registrations => "registrations"}
    devise_scope :user do 
      get 'login' => 'devise/sessions#new'
      get 'users/sign_out' => 'devise/sessions#destroy'
      get 'forgot_password' => 'devise/passwords#new'
    end
    get 'current' => 'users#current'
    get 'users/:id' => 'users#show', as: :show_user
  
    # fetch dates calendar methods
    get 'calendars/fetch_dates' => 'calendars#fetch_dates'
    get 'calendars/l2_fetch_dates' => 'calendar_l2s#fetch_dates'
    get 'calendars/l3_fetch_dates' => 'calendar_l3s#fetch_dates'
    get 'calendars/sups_fetch_dates' => 'calendar_sups#fetch_dates'
  
    # feedback forms
    match "/feedback" => redirect("https://docs.google.com/forms/d/e/1FAIpQLSdxkcvYhkhql5-39tJZE7ERjSOtw2eEfq9j-KynRV08luSAJw/viewform"), :via => [:get], :as => :feedback
  
    # home page
    root to: 'pages#index'

  # ! admin & sup shared routes
  # ============================ 
  authenticate :user, -> (u) { u.admin? || u.position == "Sup"} do
    # coverage JSON
    get 'admin/coverage' => 'admin#coverage'
    # access admin page
    get 'admin/index'
    resources :admin
    # view user profiles
    get 'users/index'
    # export pto_requests.csv
    get 'pto_requests/export_all' => 'pto_requests#export_all'
    get 'pto_requests/export_user_request/:id' => 'pto_requests#export_user_request', as: 'export_user_request'
    # excuse pto_requests
    post "pto_requests/:id/excuse_request" => 'pto_requests#excuse_request', as: :excuse_pto_request
    # no-call / no-show pto_requeset
    post "pto_requests/:id/add_no_call_show" => 'pto_requests#add_no_call_show', as: :add_no_call_show
    # remove no-call / no-show pto_requeset
    post "pto_requests/:id/sub_no_call_show" => 'pto_requests#sub_no_call_show', as: :sub_no_call_show

    resources :users  do
      # change users shift
      put :update_shift
      # change admin standing
      post :update_admin
      # pip / de-pip a user
      post :update_pip
      # send password rest on user's behalf
      post :send_password_reset
      # add pto_request for user
      post :add_request_for_user
      # delete user account 
      delete :destroy
    end

  end  
  
  # ! admin-only routes
  # ====================
  authenticate :user, -> (u) { u.admin? } do
    # import agents.csv
    get 'users/import'
    post 'users/import' => 'users#import'
    resources :users do 
      collection { post :import}
    end
    # manually update calendar base_price
    post 'calendars/update_base_price' => 'calendars#update_base_price', as: 'update_base_price'
    # import pto_requests.csv
    get 'pto_requests/import'
    resources :pto_requests do
      collection { post :import_request}
    end
    # routes for calendar.csv imports
    resources :calendars do
      collection { post :import}
    end
  end
end
