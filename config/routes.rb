Rails.application.routes.draw do
  root 'static_pages#home'
  get '/our-team', to: 'static_pages#our_team'
  get '/contact', to: 'static_pages#contact'
  get  '/signup',  to: 'users#new'
  post '/signup',  to: 'users#create'
  resources :users
end
