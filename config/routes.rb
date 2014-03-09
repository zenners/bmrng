BMRNG::Application.routes.draw do

  resources :answers


  #devise_for :users

  #mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  resources :questions

  resources :guests

  resources :albums
    
  resources :photos


  mount StripeEvent::Engine => '/stripe'
  get "content/gold"
  get "content/silver"
  get "/add", to: 'content#silver'
  get "content/platinum"

  get "home/manage"
  get "/manage", to: 'home#manage'
  get "home/analytics"
  get "/analytics", to: 'home#analytics'

  get "home/update_view"

  get "photos/update_view"

  devise_for :users, :controllers => { :registrations => 'registrations' }
  devise_scope :user do
    put 'update_plan', :to => 'registrations#update_plan'
    put 'update_card', :to => 'registrations#update_card'
    put 'update', :to => 'registrations#update'
    get 'account', :to => 'registrations#edit'
  end
  
  resources :users

  get "/display/:id", to: 'albums#display'
  get "/feedback", to: 'questions#index'

  get "/destroy_session", to: 'guests#destroy'
  get "/start_session", to: 'guests#start'

  get "/fave" => "photos#fave"
  get "/defave" => "photos#defave"

  get "/:name/:id" => 'albums#display', :as => :display, :username => /[\.a-zA-Z0-9_]+/

  root :to => 'home#index'
end