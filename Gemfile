source 'http://rubygems.org'
if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

# DO NOT REMOVE THIS LINE!
source 'https://rubygems.org'

# DO NOT ENTER GEMS WITHOUT GEM NUMBER!
# OR I WILL CUT YOUR FINGER!

# TODO: update to rails 4.0.0
# need to be updated:
# * aced_rails
# * mongoid
# * rails-backbone
# * redis-rails
gem 'rails', '3.2.13'

# twitter bootstrap as sass
gem 'bootstrap-sass', '2.3.2.0'

group :assets do
  gem 'sass-rails',   '3.2.6'
  gem 'coffee-rails', '3.2.2'
  gem 'uglifier', '2.1.1'
  gem 'compass-rails', '1.0.3'
end

# frontend
gem 'jquery-rails', '2.1.3'
gem "jquery-ui-rails", "3.0.1"
gem 'rails-backbone', '0.9.10'
gem 'haml-rails', '0.4'

# database
# TODO: before upgrade to 4.0 include mongoid-paranoia and mongoid-versioning
gem 'mongoid', '3.1.4'

# security
gem 'bcrypt-ruby', '3.1.1'

# auth
gem 'omniauth', '1.1.4'
gem 'omniauth-github', '1.1.0'

# github integration
gem 'octokit', '1.25.0'

# font with bundled icons
gem 'font-awesome-rails', '3.2.1.2'

# roles and permissions
gem 'cancan', '1.6.10'

group :development do
# remove assets-logs in console
  gem 'quiet_assets', '1.0.2'
  # faster start for rake and rails commands
  gem 'zeus',  '0.13.3'
  # profiling
  gem 'ruby-prof', '0.13.0'
  # for work with rails panel
  gem 'meta_request', '0.2.7'
  #gem 'debugger', '1.5.0'
  gem 'better_errors', '0.9.0'
  #gem 'binding_of_caller', '0.7.1'
  # web server
  gem 'thin', '1.5.1'
  # gem for creating db/controller diagrams
  gem 'railroady', '1.1.0'
  # colored output in irb and console
  gem 'wirble', '0.1.3'
end

# admin interface
gem 'rails_admin', '0.4.9'
gem 'mongoid-audit', '0.1.7'

# web-scraping
gem 'json_pure', '1.8.0'
gem 'json', '1.8.0'
gem 'httparty', '0.11.0'

# used for retrieving github-username by email
gem 'mechanize', '2.7.1'

# work with wikimarkdown
gem 'mediawiki-gateway', '0.5.1'
gem 'wikicloth', :git => 'git://github.com/avaranovich/wikicloth.git'

#rdf support
gem 'rdf', :git => 'git://github.com/ruby-rdf/rdf.git'
gem 'rdf-rdfxml', :git => 'git://github.com/ruby-rdf/rdf-rdfxml.git'
gem 'rdf-sesame', :git => 'git://github.com/avaranovich/rdf-sesame.git'

# source text highlighting
gem 'pygments.rb', '0.5.1'
gem 'closure-compiler', '1.1.10'

# growl-like notifications
gem 'gritter', :git => 'git://github.com/burgua/gritter.git', :branch => 'vendor_dir'

# deploy with Capistrano
gem 'capistrano', '2.15.5'

gem 'rvm-capistrano', '1.4.0'

gem 'redis', '3.0.4'
gem 'redis-store', '1.1.3'
gem 'redis-rails', '3.2.3'

# for wiki-editor
gem 'aced_rails', '0.2.1', :git => 'git://github.com/tschmorleiz/aced_rails.git'

gem 'bootstrap-tour-rails', '0.4.0'
