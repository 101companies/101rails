Wiki::Application.routes.draw do

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  scope 'contributions' do
    get '/' => 'contributions#index'
    get '/new' => 'contributions#new'
    post '/create' => 'contributions#create'
    get '/:id' => 'contributions#show', :as => :contribution
  end

  authenticated :user do
    root :to => 'home#index'
  end

  root :to => "home#index"
  get '/login_intro' => 'home#login_intro'
  get '/wiki' => 'pages#show'
  get '/tours' => 'tours#index'
  get '/search' => 'pages#search'
  match '/wiki/:title' => 'pages#show' , :constraints => { :id => /.*/ }
  match '/tours/:title' => 'tours#show'

  #users
  match 'registrations' => 'users#index', :as => 'registrations'
  devise_for :users, :controllers => { :registrations => 'registrations' }
  resources :users, :only => [:show, :index]

  scope 'api', :format => :json do
    post 'classify' => 'classification#classify'
    post 'parse' => 'pages#parse'
    get 'pages' => 'pages#all'
    resources :pages, :constraints => { :id => /.*/ }, :only => [:section,:show] do
      member do
        get "/" => 'pages#show'
        put "/" => 'pages#update'
        delete '/' => 'pages#delete'
        get 'sections' => 'pages#sections'
        get 'internal_links' => 'pages#internal_links'
        get 'sections/:title' => 'pages#section'
        get 'summary' => 'pages#summary'
      end
    end
  end

  scope 'endpoint', :format => :json do
    get ':id/rdf' => 'pages#get_rdf', :constraints => { :id => /.*/ }
    get ':id/json' => 'pages#get_json', :constraints => { :id => /.*/ }, :directions => false
    get ':id/json/directions' => 'pages#get_json', :constraints => { :id => /.*/ }, :directions => true
  end

  devise_for :users, :controllers => { :registrations => 'registrations' }
  resources :users, :only => [:show,:destroy]

  # AUTHENTICATIONS
  match '/auth/:provider/callback' => 'authentications#create'
  resources :authentications, :only => [:index,:create,:destroy]
  match '/auth/failure' => 'authentications#auth_failure'
end
