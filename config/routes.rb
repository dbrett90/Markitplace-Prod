Rails.application.routes.draw do
  get 'password_resets/new'
  get 'password_resets/edit'
  get 'sessions/new'
  root 'static_pages#home'
  get '/test', to: 'one_off_products#test_item'
  get '/test-index', to: 'one_off_products#test_index'
  delete '/test', to: 'carts#post_destroy'
  get '/test-index', to:'carts#post_index'
  get '/test-checkout', to: 'carts#post_checkout'
  post '/test-checkout', to: 'carts#post_complete_checkout'
  get '/send-test-email', to: 'carts#test_email'
  get '/beta-mailing-list', to: 'static_pages#beta_test_list'
  get '/home-signup-successful', to: 'stripe_connect_user#new'
  get '/our-team', to: 'static_pages#our_team'
  get '/add-to-cart', to: 'carts#add_to_cart'
  post '/add-to-cart', to: 'carts#post_add_to_cart'
  get '/guest-add-to-cart', to: 'carts#guest_add_to_cart'
  post '/guest-add-to-cart', to: 'carts#post_guest_add_to_cart'
  get '/guest-cart', to: 'carts#guest_cart_index'
  delete '/guest-cart', to: 'carts#guest_destroy'
  get '/guest-checkout', to: 'carts#guest_checkout'
  post '/guest-checkout', to: 'carts#guest_complete_checkout'
  get 'add-subscription-to-cart', to: 'carts#add_to_cart_subscription'
  get '/checkout', to: 'carts#checkout'
  post '/checkout', to: 'carts#complete_checkout'
  get '/cart', to: 'carts#index'
  delete '/cart', to: 'carts#destroy'
  get '/contact', to: 'static_pages#contact'
  get '/contact-test', to: 'static_pages#contact_test'
  post '/contact', to: 'static_pages#create'
  get '/services', to: 'static_pages#partners'
  post '/services', to: 'static_pages#partners_create'
  get '/partner-contact', to: 'static_pages#partner_contact'
  get '/terms-of-service', to: 'static_pages#terms_of_service'
  get '/privacy-policy', to: 'static_pages#privacy_policy'
  get '/stripe-partners', to: 'static_pages#stripe_partner_info'
  get '/signup-info', to: 'users#business_or_customer'
  post '/signup-info', to: 'users#business_or_customer_create'
  get  '/signup',  to: 'users#new'
  post '/signup',  to: 'users#create'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  # get '/plan-types', to: 'plan_types#index'
  get '/mealkits', to: 'products#index'
  get '/additional-products', to: 'one_off_products#index'
  get '/partners', to: 'partner_logos#index'
  get '/mealkit-playbook', to: 'partner_logos#playbook'
  post '/mealkit-playbook', to: 'partner_logos#download_playbook'
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
  resources :one_off_products
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
  resources :carts
  resources :partners, param: :name
  resources :partner_backgrounds

  ######BASIC SETUP ROUTES#######
  resources :subscriptions
  resources :purchase_one_offs
  resources :partner_logos
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]
  resources :contact_emails, only: [:edit]

  #For Sitemap capture
  get '/sitemap.xml.gz', to: redirect("https://markitplace-sitemaps.s3.us-east-2.amazonaws.com/sitemaps/sitemap.xml.gz")
end
