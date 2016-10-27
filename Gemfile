source 'https://rubygems.org'

# force using encoding
if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

gem 'rails', '4.2.3'
gem 'newrelic_rpm'
gem 'kaminari'

gem 'solid_use_case', '~> 2.1.1'

# send email on error
gem 'exception_notification', '4.0.1'

# twitter bootstrap as sass
gem 'bootstrap-sass'

gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'

gem 'responders', '~> 2.0'

# frontend
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'haml-rails'

# database
gem 'mongoid', '~> 5.0.0.beta'

# search engine
gem 'mongoid_search'

# security
gem 'bcrypt'

# github auth
gem 'omniauth', '1.2.1'
gem 'omniauth-github', '1.1.2'

# github integration
gem 'octokit', "~> 4.0"

# font with bundled icons
gem 'font-awesome-rails'

# roles and permissions
gem 'cancan', '1.6.10'

group :development, :test do
  # remove assets-logs in console
  gem 'quiet_assets', '1.0.2'
  # nice error output
  gem 'better_errors', '1.1.0'
  gem 'binding_of_caller', '0.7.2'
  # colorful console
  gem 'wirble', '0.1.3'
  gem 'zeus', '0.15.1'
  gem 'rack-mini-profiler'
  gem 'rspec-rails', '~> 3.3.0'
  gem 'mongoid-rspec', '3.0.0'
  gem 'simplecov', require: false
  gem 'factory_girl_rails'

  gem 'capistrano-rails',   '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  gem 'capistrano3-puma', github: "seuros/capistrano-puma"
  gem 'capistrano-rvm'
end

gem 'awesome_print'

# web server
gem 'puma'

gem 'colorize', '0.7.3'

# admin interface
gem 'rails_admin'

# web-scraping
gem 'json_pure'
gem 'json'
gem 'httparty', '0.13.1'

# work with mediawiki
gem 'mediawiki-gateway', '0.6.0'

# work with wiki markdown
gem 'wikicloth', :github => '101companies/wikicloth'

gem 'rdf', :github => 'ruby-rdf/rdf'

# source text highlighting
gem 'pygments.rb', '0.5.4'
gem 'closure-compiler', '1.1.10'

# better work with form -> bindings to models
gem 'simple_form'

# intelligent select
gem 'select2-rails', '3.5.7'

# work with time in js
gem 'momentjs-rails'

# ui for diff
gem 'differ', '0.1.2'

# growl-like notifications
gem 'humane-rails'

# deploy tool
# update only after reading upgrade manual
# gem 'capistrano', '2.15.5'
# locking 2 gems to prevent failing updates with capistrano
# gem 'net-ssh', '2.7.0'
# gem 'net-ssh-gateway', '1.2.0'

# for wiki-editor
gem 'aced_rails', '0.3.1', :github => '101companies/aced_rails'

gem 'bootstrap-tour-rails', '0.4.0'

gem 'eventmachine', '1.0.4'
gem 'em-http-request', '1.1.2'

# gem 'syck'

gem 'react-rails', '~> 1.4.0'

gem 'jbuilder'

#linked open data
gem 'linkeddata'
gem 'rdf-json'
gem 'rdf-rdfxml'
gem 'rdf-turtle'
gem 'rdf-n3'