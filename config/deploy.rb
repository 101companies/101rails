# config valid only for current version of Capistrano
lock '3.4.0'

set :application, "101wiki"
set :repo_url, "git://github.com/101companies/101rails.git"
set :user, 'ubuntu'

set :keep_releases, 5

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_application
set :deploy_to, "/home/ubuntu/101rails"

set :puma_workers, 1
set :puma_threads, [0, 2]

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 2
#
# on roles :all do
#   within fetch(:latest_release_directory) do
#     with rails_env: fetch(:rails_env) do
#       execute :rake, 'assets:precompile'
#     end
#   end
# end

namespace :foreman do
  desc "Export the Procfile to Ubuntu's upstart scripts"
  task :export do
    on roles(:app) do
      puts "cd #{current_path} && sudo foreman export upstart /etc/init -a #{fetch(:application)} -u #{fetch(:user)} -l /var/#{fetch(:application)}/log"
      execute "cd #{current_path} && sudo foreman export upstart /etc/init -a #{fetch(:application)} -u #{fetch(:user)} -l /var/#{fetch(:application)}/log"
    end
  end

  desc "Start the application services"
  task :start do
    on roles(:app) do
      execute "sudo service #{fetch(:application)} start"
    end
  end

  desc "Stop the application services"
  task :stop do
    on roles(:app) do
      execute "sudo service #{fetch(:application)} stop"
    end
  end

  desc "Restart the application services"
  task :restart do
    on roles(:app) do
      execute "sudo service #{fetch(:application)} start || sudo service #{fetch(:application)} restart"
    end
  end
end
