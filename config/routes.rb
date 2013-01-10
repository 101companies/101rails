Wiki::Application.routes.draw do
  #match "101implementation:title" => "pages#show"

  authenticated :user do
    root :to => 'home#index'
  end

  root :to => "home#index"
  get '/data' => 'home#data'
  match '/Category/:title' => 'category_pages#show'
  match '/:title' => 'pages#show'

  #users
  match 'registrations' => 'users#index', :as => 'registrations'
  devise_for :users, :controllers => { :registrations => 'registrations' }
  resources :users, :only => [:show, :index]

  scope 'api', :format => :json do
    post 'classify' => 'classification#classify'
    resources :pages, :only => [:section,:show] do
      member do
        put "/" => "pages#update"
        get 'sections' => 'pages#sections'
        get 'sections/:title' => 'pages#section'
      end
    end
  end

  devise_for :users, :controllers => { :registrations => 'registrations' }
  resources :users, :only => [:show,:destroy]

  # AUTHENTICATIONS
  match '/auth/:provider/callback' => 'authentications#create'
  resources :authentications, :only => [:index,:create,:destroy]
  match '/auth/failure' => 'authentications#auth_failure'
end
