Wiki::Application.routes.draw do

  resources :mappings
  resources :books, except: [:show] do
    post :create_index, on: :member
    resources :chapters, only: [:new, :edit, :update, :destroy, :create]
  end
  namespace :admin do
    get '/', to: 'admin#index'
    resources :pages
    resources :users
  end

  resources :scripts, only: [:show]

  # homepage
  root to: "landing#index"
  # sitemap
  get '/sitemap.xml' => 'application#sitemap'
  # link for downloading slides from slideshare
  get '/get_slide/*slideshare' => 'application#get_slide', format: false

  get '/autocomplete' => 'autocomplete#index'

  get '/search' => 'pages#search'
  get '/contributors_without_github_name' => 'application#contributors_without_github_name'
  get '/pullRepo.json' => 'application#pull_repo'

  post '/last_received' => 'messages#last_received'

  # urls for contribution process
  scope 'contribute' do
    # ui for creating contribution
    get '/new' => 'contributions#new'
    get '/apply_findings/:id' => 'pages#apply_findings', constraints: { id: /.*/ }
    post '/update/:id' => 'pages#update_repo', constraints: { id: /.*/ }
    put '/update/:id' => 'pages#update_repo', constraints: { id: /.*/ }
    # method where contribution will be created
    post '/analyze/:id' => 'contributions#analyze', constraints: { id: /.*/ }
    post '/new' => 'contributions#create'
    get '/repo_dirs/:repo' => 'contributions#get_repo_dirs', constraints: { repo: /.*/ }
  end

  # linked open data (regex for accept resource_names with dots in it)
  scope 'resource' do
    get '/' => 'resource#landing'
    get ':resource_name' => 'resource#get', :resource_name => /([^\/]+?)(?=\.json|\.ttl|\.n3|\.xml|\.html|$|\/)/
  end

  # tours
  scope 'tours' do
    get '/' => 'tours#index'
    get '/:title' => 'tours#show'
  end

  # tours api
  scope 'api/tours' do
    get ':title' => 'tours#show', as: :tour
    put ':title' => 'tours#update'
    delete ':title' => 'tours#delete'
  end

  get 'users/logout' => 'authentications#destroy'

  # clones
  scope 'clones' do
    get '/new' => 'clones#show_create'
    get '/' => 'clones#show'
    get '/check/:title' => 'clones#show'
  end

  scope '/api/wiki/' do
    get '/:id' => 'api_pages#show', defaults: { format: :json }
  end

  # routes for work with history
  scope 'page_changes' do
    get 'all/:page_id' => 'page_changes#get_all'
    # compare with current revision
    get 'diff/:page_change_id' => 'page_changes#diff'
    # compare two revisions
    get 'diff/:page_change_id/:another_page_change_id' => 'page_changes#diff'
    get 'show/:page_change_id' => 'page_changes#show'
    get 'apply/:page_change_id' => 'page_changes#apply'
  end

  # json api requests for pages
  scope 'api', format: :json do
    # clones api
    get 'clones/:title' => 'clones#get'
    post 'clones/:title' => 'clones#create'
    put 'clones/:title' => 'clones#update'
    get 'clones/:title' => 'clones#get'
    delete 'clones/:title' => 'clones#delete'
    get 'clones' => 'clones#index'
  end

  # authentications
  scope 'auth' do
    match '/github/callback' => 'authentications#create', via: [:get, :post]
    match '/failure' => 'authentications#failure', via: [:get, :post]
    match '/local_login/:admin' => 'authentications#local_auth', via: [:get, :post]
  end

  # pages routes
  resources :pages, path: '/', id: /.*/ do
    get :unverified, on: :collection
    post :verify, on: :member
    get :unverify, on: :member
    get :create_new_page, on: :member
    get :create_new_page_confirmation, on: :member
    put :rename, on: :member
  end
end
