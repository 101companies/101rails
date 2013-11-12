Wiki::Application.routes.draw do

  # homepage
  root :to => "home#index"
  get '/search' => 'pages#search'
  # sitemap
  get '/sitemap.xml' => 'application#sitemap'
  # link for downloading slides from slideshare
  get '/get_slide/*slideshare' => 'application#get_slide', :format => false

  # admin ui
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  # urls for contribution process
  scope 'contribute' do
    # list of contributions
    get '/' => 'contributions#index'
    # ui for creating contribution
    get '/new' => 'contributions#new'
    post '/apply_findings/:id' => 'pages#apply_findings', :constraints => { :id => /.*/ }
    put '/update/:id' => 'pages#update_repo', :constraints => { :id => /.*/ }
    # method where contribution will be created
    post '/new' => 'contributions#create'

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
    get '/claim_pages' => 'users#claim_pages', :format => false
    get '/logout' => 'authentications#destroy'
    get '/:id' => 'users#show', :as => :user
  end

  # clones
  scope 'clones' do
    get '/new' => 'clones#show_create'
    get '/' => 'clones#show'
    get '/check/:title' => 'clones#show'
  end


  # pages routes
  scope 'wiki' do
    get '/' => redirect("/wiki/@project")
    match '/:id' => 'pages#show' , :constraints => { :id => /.*/ }, :as => :page
  end

  get 'snapshot/:id' => 'pages#snapshot', :constraints => { :id => /.*/ }, :as => :page

  # json api requests for pages
  scope 'api', :format => :json do
    post 'parse' => 'pages#parse'
    get 'clones/:title' => 'clones#get'
    post 'clones/:title' => 'clones#create'
    put 'clones/:title' => 'clones#update'
    get 'clones/:title' => 'clones#get'
    delete 'clones/:title' => 'clones#delete'
    get 'clones' => 'clones#index'
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
    match '/github/callback' => 'authentications#create'
    match '/failure' => 'authentications#failure'
  end
end
