Rails.application.routes.draw do
  get 'import_date_csv/index'
  get 'import_date_csv/import'
  resources :import_date_csv do
  	collection { post :import}
  end
  devise_for :users, :controllers => {:registrations => "registrations"}
  devise_scope :user do 
    get 'login', to: 'devise/sessions#new'
  end

  devise_scope :user do
    get 'signup', to: 'devise/registrations#new'
  end
  
  root to: 'pages#index'
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
