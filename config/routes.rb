Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  get 'sessions/new'
  root 'static_pages#home'
  get '/home-signup-successful', to: 'stripe_connect_user#new'
  get '/our-team', to: 'static_pages#our_team'
  get '/contact', to: 'static_pages#contact'
  get '/contact-test', to: 'static_pages#contact_test'
  post '/contact', to: 'static_pages#create'
  get '/partner-information', to: 'static_pages#partners'
  post '/partner-information', to: 'static_pages#partners_create'
  get 'partner-contact', to: 'static_pages#partner_contact'
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
  # resources :products, only: [:index]
  #little bit of logic to determine where you should go
  resources :products do
    member do
      put "add", to: "products#library"
      put "remove", to: "products#library"
    end
  end
  #Look into the pricing controller needed here?
  # Resources pricing, only: [:index]
  resources :products
  resources :product_subscription_library, only: [:index] 

  ####MEAL KIT PLAN ROUTE SETUP######
  resources :plan_types do
    member do
      put "add", to: "plan_types#library"
      put "remove", to: "plan_types#library"
    end
  end
  resources :plan_types 
  resources :plan_subscription_library, only: [:index]

  ######BASIC SETUP ROUTES#######
  resources :subscriptions
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :contact_emails, only: [:edit]

  #For Sitemap capture
  get '/sitemap.xml.gz', to: redirect("https://markitplace-sitemaps.s3.us-east-2.amazonaws.com/sitemaps/sitemap.xml.gz")
end
