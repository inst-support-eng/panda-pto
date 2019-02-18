Rails.application.routes.draw do
<<<<<<< HEAD
  get 'import_date_csv/index'
  get 'import_date_csv/import'
  resources :import_date_csv do
  	collection { post :import}
  end
=======
  get 'date_values/index'
  get 'date_values/import'
  resources :date_values do
  	collection { post :import}
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
>>>>>>> a150e1b568eb01e58e150de67e386776b5cc0671
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
