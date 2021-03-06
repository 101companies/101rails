Wiki::Application.routes.draw do
  resources :create_wiki_metrics

  resources :mappings, only: %i[edit update]

  constraints(id: %r{([^/]+?)(?=\.json|\.ttl|\.n3|\.xml|\.html|$|/)}) do
    resources :resources, only: %i[index show] do
      get :query, to: 'resources#query', on: :collection
    end
  end

  resources :books, except: [:show] do
    post :create_index, on: :member
    resources :chapters, only: %i[new edit update destroy create]
  end

  namespace :admin do
    get '/', to: 'admin#index'
    resources :pages
    resources :users
  end

  resources :scripts, only: [:show]

  # homepage
  root to: 'landing#index'
  # sitemap
  get '/sitemap.xml' => 'application#sitemap'
  # link for downloading slides from slideshare
  get '/get_slide/*slideshare' => 'application#get_slide', :format => false

  get '/autocomplete' => 'autocomplete#index'

  get '/search' => 'pages#search'
  get '/contributors_without_github_name' => 'application#contributors_without_github_name'
  get '/pullRepo.json' => 'application#pull_repo'

  # urls for contribution process
  scope 'contribute' do
    # ui for creating contribution
    get '/new' => 'contributions#new'
    get '/apply_findings/:id' => 'pages#apply_findings', :constraints => { id: /.*/ }
    post '/update/:id' => 'pages#update_repo', :constraints => { id: /.*/ }
    put '/update/:id' => 'pages#update_repo', :constraints => { id: /.*/ }
    # method where contribution will be created
    post '/analyze/:id' => 'contributions#analyze', :constraints => { id: /.*/ }
    post '/new' => 'contributions#create'
    get '/repo_dirs/:repo' => 'contributions#get_repo_dirs', :constraints => { repo: /.*/ }
  end

  get 'users/logout' => 'authentications#destroy'

  # routes for work with history
  scope 'page_changes' do
    get 'index' => 'page_changes#index'
    get 'all/:page_id' => 'page_changes#get_all'
    # compare with current revision
    get 'diff/:page_change_id' => 'page_changes#diff'
    # compare two revisions
    get 'diff/:page_change_id/:another_page_change_id' => 'page_changes#diff'
    get 'show/:page_change_id' => 'page_changes#show'
    get 'apply/:page_change_id' => 'page_changes#apply'
  end

  # authentications
  scope 'auth' do
    match '/github/callback' => 'authentications#create', :via => %i[get post]
    match '/local_login/:admin' => 'authentications#local_auth', :via => %i[get post]
  end

  resources :pages, only: [:index]

  # pages routes
  resources :pages, path: '/', id: %r{([^/]+?)(?=\.json|\.ttl|\.n3|\.xml|\.html|$|/)} do
    get :unverified, on: :collection
    post :verify, on: :member
    get :unverify, on: :member
    get :create_new_page, on: :member
    get :create_new_page_confirmation, on: :member
    put :rename, on: :member
  end

  scope '/wiki' do
    match '(*path)' => redirect { |params, _req|
      URI.encode("/#{params[:path]}")
    }, :via => %i[get post]
  end

  # routes for Software Analysis as a Service
  get '/service/', to: 'services#index'
  post '/service/manage', to: 'services#manage'
  post '/service/reset', to: 'services#reset'
  post '/service/stop', to: 'services#stop'
  post 'reload', to: 'repos#getInfoAsync'
  post 'repos/reqDownload', to: 'repos#sendDownload'
  resources :repos, param: :name, only: %i[index show create destroy] do
    resources :parts, param: :name, only: %i[show create destroy]
  end
end
