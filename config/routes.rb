Wiki::Application.routes.draw do

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  scope 'contributions' do
    get '/' => 'contributions#index'
    get '/new' => 'contributions#new'
    post '/create' => 'contributions#create'
    get '/:id' => 'contributions#show', :as => :contribution
  end

  root :to => "home#index"
  get '/login_intro' => 'home#login_intro'
  get '/tours' => 'tours#index'
  get '/search' => 'pages#search'
  match '/tours/:id' => 'tours#show'

  scope 'api/tours' do
    get ':title' => 'tours#show'
    put ':title' => 'tours#update'
    delete ':title' => 'tours#delete'
  end

  #users
  match 'registrations' => 'users#index', :as => 'registrations'
  devise_for :users, :controllers => { :registrations => 'registrations' }
  resources :users, :only => [:show, :index]

  # pages routes
  get '/wiki' => redirect("/wiki/@project")
  match '/wiki/clean_cache/:id' => 'pages#clean_cache' , :constraints => { :id => /.*/ }
  match '/wiki/:id' => 'pages#show' , :constraints => { :id => /.*/ }

  # json api requests for pages
  scope 'api', :format => :json do
    post 'parse' => 'pages#parse'
    get 'pages' => 'pages#all'
    resources :pages, :constraints => { :id => /.*/ }, :only => [:section,:show] do
      member do
        get "/" => 'pages#show'
        put "/" => 'pages#update'
        delete '/' => 'pages#delete'
        get 'sections' => 'pages#sections'
        get 'internal_links' => 'pages#internal_links'
        get 'sections/:id' => 'pages#section'
      end
    end
  end

  # TODO: speak with Andrei
  scope 'endpoint', :format => :json do
    get ':id/rdf' => 'pages#get_rdf', :constraints => { :id => /.*/ }
    get ':id/json' => 'pages#get_json', :constraints => { :id => /.*/ }, :directions => false
    get ':id/json/directions' => 'pages#get_json', :constraints => { :id => /.*/ }, :directions => true
    get ':id/summary' => 'pages#summary', :constraints => { :id => /.*/ }
  end

  devise_for :users, :controllers => { :registrations => 'registrations' }
  resources :users, :only => [:show,:destroy]

  # AUTHENTICATIONS
  match '/auth/:provider/callback' => 'authentications#create'
  resources :authentications, :only => [:index,:create,:destroy]
  match '/auth/failure' => 'authentications#auth_failure'
end
