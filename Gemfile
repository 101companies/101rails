source 'https://rubygems.org'
gem 'rails', '3.2.8'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'compass-rails'
end

# frontend
gem 'jquery-rails'
gem 'rails-backbone'
gem 'haml-rails'

# web server
gem 'thin', '1.5.0'

# database
gem 'mongoid', '>= 3.0.5'

# security
gem 'bcrypt-ruby', '~> 3.0.0'

# auth
gem 'devise', '>= 2.1.2'
gem 'omniauth-identity'
gem 'omniauth'#, :git => 'git://github.com/intridea/omniauth.git'
gem 'omniauth-github'#, :git => 'git://github.com/intridea/omniauth-github.git'

# roles and permissions
gem 'cancan'

# faster rails command
group :development do
  gem 'zeus',  '0.13.2'
end

group :test do

  gem 'capybara', '>= 1.1.2'
  gem 'database_cleaner', '>= 0.8.0'
  gem 'mongoid-rspec', '>= 1.4.6'
  gem 'email_spec', '>= 1.2.1'
  gem 'cucumber-rails', '>= 1.3.0', :require => false

end

# admin interface
gem 'rails_admin', :git => 'git://github.com/sferik/rails_admin.git'

# testing
gem 'factory_girl_rails', '>= 4.0.0', :group => [:development, :test]
gem 'rspec-rails', '>= 2.11.0', :group => [:development, :test]

# ???
gem 'launchy', '>= 2.1.2', :group => :test

# web-scraping?
gem 'json_pure'
gem 'json'
gem 'httparty'

# work with wikimarkdown
gem 'mediawiki-gateway', :git => 'git://github.com/kubicek/mediawiki-gateway.git'
gem 'wikicloth', :git => 'git://github.com/avaranovich/wikicloth.git'

# source text highlighting
gem 'pygments.rb', '~> 0.2.13'
gem 'closure-compiler'

# deploy with Capistrano
gem 'capistrano'
gem 'capistrano_rsync_with_remote_cache'
gem 'rvm-capistrano'
