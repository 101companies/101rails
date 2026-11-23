ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

# concurrent-ruby >= 1.3.5 no longer requires 'logger' implicitly, which breaks
# Rails' ActiveSupport boot. Required explicitly so boot order is deterministic.
require 'logger'
