#require "rvm/capistrano"  
require 'bundler/capistrano'

logger.level = Logger::DEBUG

set :application, "101wiki"
set :rake, "#{rake} --trace"

set :scm, :git
#set :scm_command, "/usr/local/bin/git"
#set :local_scm_command, "/usr/local/bin/git"

# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "beta.101companies.org"                          # Your HTTP server, Apache/etc
role :app, "beta.101companies.org"                          # This may be the same as your `Web` server
role :db,  "beta.101companies.org", :primary => true # This is where Rails migrations will run

set :user, "user101"
set :host, 'beta.101companies.org'

default_run_options[:pty] = true  # Must be set for the password prompt
                                  # from git to work
set :repository, "git://github.com/101companies/101rails.git"  # Your clone URL
set :branch, "master"
set :use_sudo, true
set :user, "user101"

set :deploy_to, "/home/user101/wiki"
set :deploy_via, :rsync_with_remote_cache #:remote_cache.
ssh_options[:forward_agent] = true
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")] 

#set :rvm_ruby_string, '1.9.3@101wiki'
#set :rvm_type, :user

#set :user, "deployer"  # The server's user for deploys
#set :scm_passphrase, "p@ssw0rd"  # The deploy user's password

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"
#before "deploy:update_code", "deploy:compress_assets"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
 namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
 end

namespace :deploy do
  namespace :assets do
    desc 'Run the precompile task locally and rsync with shared'
    task :precompile, :roles => :web, :except => { :no_release => true } do
      %x{bundle exec rake assets:precompile}
      %x{rsync --recursive --times --rsh=ssh --compress --human-readable --progress public/assets #{user}@#{host}:#{shared_path}}
      %x{bundle exec rake assets:clean}
    end
  end
end
