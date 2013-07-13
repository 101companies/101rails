Wiki::Application.routes.draw do

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  scope 'contribute' do
    # list of contributions
    get '/' => 'contributions#index'
    # ui for creating contribution
    get '/new' => 'contributions#new'
    # method where contribution will be created
    post '/create' => 'contributions#create'
    # show contribution
    get '/:id' => 'contributions#show', :as => :contribution
    # put analyzed by worker data to contribution
    post '/analyze/:id' => 'contributions#analyze'
  end

  root :to => "home#index"
  get '/tours' => 'tours#index'
  get '/search' => 'pages#search'
  match '/tours/:title' => 'tours#show'

  # sitemap
  get '/sitemap.xml' => 'application#sitemap'

  scope 'api/tours' do
    get ':title' => 'tours#show', :as => :tour
    put ':title' => 'tours#update'
    delete ':title' => 'tours#delete'
  end

  #users
  scope 'users' do
    get '/' => 'users#index'
    get '/logout' => 'authentications#destroy'
    get '/:id' => 'users#show', :as => :user
  end

  # pages routes
  get '/wiki' => redirect("/wiki/@project")
  match '/wiki/clean_cache/:id' => 'pages#clean_cache' , :constraints => { :id => /.*/ }
  match '/wiki/:id' => 'pages#show' , :constraints => { :id => /.*/ }, :as => :page

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

  scope 'endpoint', :format => :json do
    get ':id/rdf' => 'pages#get_rdf', :constraints => { :id => /.*/ }
    get ':id/json' => 'pages#get_json', :constraints => { :id => /.*/ }, :directions => false
    get ':id/json/directions' => 'pages#get_json', :constraints => { :id => /.*/ }, :directions => true
    get ':id/summary' => 'pages#summary', :constraints => { :id => /.*/ }
  end

  # AUTHENTICATIONS
  match '/auth/:provider/callback' => 'authentications#create'
  match '/auth/failure' => 'authentications#auth_failure'
end
