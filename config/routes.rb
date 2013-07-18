Wiki::Application.routes.draw do

  # homepage
  root :to => "home#index"
  get '/search' => 'pages#search'
  # sitemap
  get '/sitemap.xml' => 'application#sitemap'

  # admin ui
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  # urls for contribution process
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

  # tours
  scope 'tours' do
    get '/' => 'tours#index'
    match '/:title' => 'tours#show'
  end

  # tours api
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
  scope 'wiki' do
    get '/' => redirect("/wiki/@project")
    match '/clean_cache/:id' => 'pages#clean_cache' , :constraints => { :id => /.*/ }
    match '/:id' => 'pages#show' , :constraints => { :id => /.*/ }, :as => :page
  end

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

  # authentications
  scope 'auth' do
    match '/:provider/callback' => 'authentications#create'
    match '/failure' => 'authentications#failure'
  end
end
