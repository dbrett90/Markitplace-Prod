Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  get 'sessions/new'
  root 'static_pages#home'
  get '/home-signup-successful' to: 'users_controller#grab_stripe_details'
  get '/our-team', to: 'static_pages#our_team'
  get '/contact', to: 'static_pages#contact'
  post '/contact', to: 'static_pages#create'
  get '/partner-information', to: 'static_pages#partners'
  post '/partner-information', to: 'static_pages#partners_create'
  get '/signup-info', to: 'users#business_or_customer'
  post '/signup-info', to: 'users#business_or_customer_create'
  get '/signup-secure', to: 'stripe_signup#stripe_signup'
  get  '/signup',  to: 'users#new'
  post '/signup',  to: 'users#create'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :contact_emails, only: [:edit]
end
