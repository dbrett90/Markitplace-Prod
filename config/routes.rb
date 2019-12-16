Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  get 'sessions/new'
  root 'static_pages#home'
  get '/home-signup-successful', to: 'stripe_connect_user#new'
  get '/our-team', to: 'static_pages#our_team'
  get '/contact', to: 'static_pages#contact'
  post '/contact', to: 'static_pages#create'
  get '/partner-information', to: 'static_pages#partners'
  post '/partner-information', to: 'static_pages#partners_create'
  get '/signup-info', to: 'users#business_or_customer'
  post '/signup-info', to: 'users#business_or_customer_create'
  get  '/signup',  to: 'users#new'
  post '/signup',  to: 'users#create'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  get '/mealkits', to: 'products#index'
  resources :users
  resources :stripe_connect_users
  #Below routes specifically for product library
  resources :stripe_subscriptions
  resources :products, only: [:index] 
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :contact_emails, only: [:edit]
  resources :product_subscription_library, only: [:index]
end
