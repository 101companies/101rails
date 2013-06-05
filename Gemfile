if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

# DO NOT ENTER GEMS WITHOUT GEM NUMBER!
# OR I WILL CUT YOUR FINGER!

source 'https://rubygems.org'
gem 'rails', '3.2.13'

# freezed, dependecy for rails_admin
gem 'bootstrap-sass', '2.3.1.0'

group :assets do
  gem 'sass-rails',   '3.2.6'
  gem 'coffee-rails', '3.2.2'
  gem 'uglifier', '2.1.0'
  gem 'compass-rails', '1.0.3'
end

# frontend
gem 'jquery-rails', '2.1.3'
gem 'rails-backbone', '0.9.0'
gem 'haml-rails', '0.4'

# database
gem 'mongoid', '3.1.4'

# security
gem 'bcrypt-ruby', '3.0.1'

# auth
gem 'devise', '2.2.4'
gem 'omniauth-identity', '1.1.0'
gem 'omniauth', '1.1.4'
gem 'omniauth-github', '1.1.0'

# github integration
gem 'github_api', '0.9.7'

# font with bundled icons
gem 'font-awesome-sass-rails', '3.0.2.2'

# roles and permissions
gem 'cancan', '1.6.10'

# faster rails command
group :development do
  # faster start for rake and rails commands
  gem 'zeus',  '0.13.3'
  # for work with rails panel
  gem 'meta_request', '0.2.6'
  #gem 'debugger', '1.5.0'
  gem 'better_errors', '0.8.0'
  #gem 'binding_of_caller', '0.7.1'
  # web server
  gem 'thin', '1.5.1'
  # gem for creating db/controller diagrams
  gem 'railroady', '1.1.0'
end

# gem for retrieving gravatar/github avatars
gem 'gravatar_image_tag', '1.1.3'

# admin interface
gem 'rails_admin', '0.4.8'

# web-scraping
gem 'json_pure', '1.8.0'
gem 'json', '1.8.0'
gem 'httparty', '0.11.0'

# used for retrieving github-username by email
gem 'mechanize', '2.6.0'

# work with wikimarkdown
gem 'mediawiki-gateway', '0.5.1'
gem 'wikicloth', :git => 'git://github.com/avaranovich/wikicloth.git'

#rdf support
gem 'rdf', :git => 'git://github.com/ruby-rdf/rdf.git'
gem 'rdf-rdfxml', :git => 'git://github.com/ruby-rdf/rdf-rdfxml.git'
gem 'rdf-sesame', :git => 'git://github.com/avaranovich/rdf-sesame.git'

# source text highlighting
gem 'pygments.rb', '0.5.0'
gem 'closure-compiler', '1.1.8'

# growl-like notifications
gem 'gritter', :git => 'git://github.com/burgua/gritter.git', :branch => 'vendor_dir'

# deploy with Capistrano
gem 'capistrano', '2.15.4'

gem 'rvm-capistrano', '1.3.0'

gem 'newrelic_rpm', '3.6.2.96'
gem 'redis', '3.0.4'
gem 'redis-store', '1.1.3'
gem 'redis-rails', '3.2.3'

# for wiki-editor
gem 'aced_rails', '0.2.1', :git => 'git://github.com/tschmorleiz/aced_rails.git'
