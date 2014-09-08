BMRNG::Application.routes.draw do

  get '/blog', to: redirect("http://google.com")

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
    resources :subscriptions
    match :send_feedback, via: [:get, :post]
    member do
      get :analytics
      get :manage
      get :update_view
      match :change, via: [:get, :post, :patch]
      match :welcome, via: [:get]
      match :set_human_name, via: [:patch, :post]
      match :set_studio, via: [:get, :post]
      match :set_url, via: [:get, :post]
      match :set_logo, via: [:get, :post]
      match :set_questions, via: [:get, :post]
      match :welcome_complete, via: [:get]
    end
  end

  resources :guests do
    collection do
      get :destroy_session
      get :start_session
      get :load
      get :save
      match :ask_questions, via: [:get, :post]
      get :thank_you
    end
  end

  resources :albums do
    member do
      get :display
      match :set_title, via: [:get, :post, :patch]
      match :set_password, via: [:get, :patch]
      match :settings, via: [:get, :post, :patch]
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

  get "/feedback", to: 'questions#index'

  get '/admin/become' => 'admin#become'

  constraints DomainConstraint.new ['myalbumviewer.dev', 'myalbumviewer.com'] do
    root to: 'home#viewer', as: :viewer
    resources :users, path: '/' do
      get '/:album_id' => 'albums#display'
    end
  end

  root :to => 'home#index', as: :home
end