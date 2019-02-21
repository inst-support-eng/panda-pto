Rails.application.routes.draw do
  get 'agents/index'
  get 'agents/import'
  get 'date_values/index'
  get 'date_values/import'
  resources :date_values do
  	collection { post :import}
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  devise_for :users, :controllers => {:registrations => "registrations"}
  devise_scope :user do 
    get 'login', to: 'devise/sessions#new'
  end

  devise_scope :user do
    get 'signup', to: 'devise/registrations#new'
  end
  
  root to: 'pages#index'
end
