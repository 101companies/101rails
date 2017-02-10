#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("../config/environment", __FILE__)
# require File.expand_path("../db/view_schema", __FILE__)

# require File.expand_path('../app/page/page_projector', __FILE__)

begin
  require 'sequent/rake/tasks'
  Sequent::Rake::Tasks.new({
    db_config_supplier: YAML.load_file('config/database.yml'),
    environment: ENV['RAILS_ENV'] || 'development',
    view_projection: Sequent::Support::ViewProjection.new(
      name: 'view_schema',
      version: 1,
      event_handlers: [PageProjector.new],
      definition: 'db/view_schema.rb'
    )
  }).register!
rescue LoadError
  puts 'Sequent tasks are not available'
end

Wiki::Application.load_tasks
