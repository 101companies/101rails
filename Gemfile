source 'https://rubygems.org'
ruby '3.3.10'

gem 'concurrent-ruby'
gem 'json', '~> 2.6' # json 3.x dropped quirks_mode, which Rails 6.1 JSON encoding needs
gem 'html2text'
gem 'listen'
gem 'oj'
gem 'pg'
gem 'pg_search'
gem 'rails', '~> 7.2.0'
# Rails 7 no longer depends on sprockets-rails; the app still uses
# stylesheet_link_tag / app/assets, so opt back in (replaced by propshaft later).
gem 'sprockets-rails'
gem 'ruby-stemmer', '>=0.8.3', require: 'lingua/stemmer'
gem 'scenic'
gem 'view_component'
gem 'webpacker'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

gem 'parslet', git: 'https://github.com/kschiess/parslet.git'

# send email on error
gem 'exception_notification'

# github auth
gem 'omniauth'
gem 'omniauth-github'
gem 'solid_use_case', github: 'kevin-klein/solid_use_case'
# github integration
gem 'octokit'
gem 'rexml'
# roles and permissions
gem 'cancancan'

gem 'validate_url'

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'rubocop-github'
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false
end

gem 'awesome_print'

# web server
gem 'puma'

gem 'chartkick'
gem 'groupdate'

# work with wiki markdown
gem 'wikicloth', git: 'https://github.com/101companies/wikicloth'

# source text highlighting
gem 'pygments.rb'

# better work with form -> bindings to models
gem 'simple_form'

# ui for diff
gem 'differ'

gem 'react-rails'

gem 'jbuilder'

gem 'rack-mini-profiler'
