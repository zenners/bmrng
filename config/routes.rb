BMRNG::Application.routes.draw do

  resources :answers

  #mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  resources :questions

  devise_for :users, :controllers => { :registrations => 'registrations' }
  devise_scope :user do
    put 'update_plan', :to => 'registrations#update_plan'
    put 'update_card', :to => 'registrations#update_card'
    put 'update', :to => 'registrations#update'
    get 'account', :to => 'registrations#edit'
  end

  resources :users do
    member do
      get :analytics
      get :manage
      get :update_view
    end
  end

  resources :guests do
    collection do
      get :destroy_session
      get :start_session
      get :load
    end
  end

  resources :albums do
    member do
      get :display
    end
    resources :photos do
      member do
        get :display
      end
    end
  end
    
  resources :photos do
    member do
      get :fave
      get :defave
    end
  end

  mount StripeEvent::Engine => '/stripe'

  get "home/update_view"

  get "photos/update_view"

  #get "/display/:id", to: 'albums#display'
  get "/feedback", to: 'questions#index'

  #get "/destroy_session", to: 'guests#destroy'
  #get "/start_session", to: 'guests#start'

  get "/:name/:id" => 'albums#display', :as => :display, :username => /[\.a-zA-Z0-9_]+/

  root :to => 'home#index'
end