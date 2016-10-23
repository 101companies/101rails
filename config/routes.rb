Wiki::Application.routes.draw do

  namespace :admin do
    resources :pages
    resources :users
  end

  # mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  # homepage
  root to: "application#landing_page"
  # sitemap
  get '/sitemap.xml' => 'application#sitemap'
  # link for downloading slides from slideshare
  get '/get_slide/*slideshare' => 'application#get_slide', format: false

  get '/autocomplete' => 'autocomplete#index'

  get '/search' => 'pages#search'
  get '/contributors_without_github_name' => 'application#contributors_without_github_name'
  get '/pullRepo.json' => 'application#pull_repo'

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

  # linked open data
  get 'resource/:resource_name' => 'resource#get'

  get 'resource' => 'resource#get', resource_name: '101linkeddata'

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

  # pages routes
  resources :pages, path: 'wiki' do
    get :unverified, on: :collection
    post :verify, on: :member
    get :unverify, on: :member
    get :create_new_page, on: :member
    get :create_new_page_confirmation, on: :member
    put :rename, on: :member
    get :render_script, on: :member
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
end
