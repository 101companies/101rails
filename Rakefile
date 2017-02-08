#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

begin
  require 'sequent/rake/tasks'
  Sequent::Rake::Tasks.new({db_config_supplier: YAML.load_file('config/database.yml'), environment: ENV['RAILS_ENV'] || 'development'}).register!
rescue LoadError
  puts 'Sequent tasks are not available'
end

Wiki::Application.load_tasks
