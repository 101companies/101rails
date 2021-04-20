# preload_app!

rackup      DefaultRackup
port        ENV['PORT'] || 3000
environment ENV['RAILS_ENV'] || 'production'


threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads threads_count, threads_count
