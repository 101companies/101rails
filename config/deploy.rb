require "rvm/capistrano"  
require 'bundler/capistrano'

logger.level = Logger::DEBUG

set :application, "101wiki"
set :rake, "#{rake} --trace"

set :scm, :git
set :scm_command, "/usr/local/bin/git"
set :local_scm_command, "/usr/local/bin/git"

# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "sl-mac.uni-koblenz.de"                          # Your HTTP server, Apache/etc
role :app, "sl-mac.uni-koblenz.de"                          # This may be the same as your `Web` server
role :db,  "sl-mac.uni-koblenz.de", :primary => true # This is where Rails migrations will run

default_run_options[:pty] = true  # Must be set for the password prompt
                                  # from git to work
set :repository, "git://github.com/101companies/101rails.git"  # Your clone URL
set :branch, "master"
set :use_sudo, true
set :user, "wiki101"

set :deploy_to, "/Users/wiki101/Sites/101wiki"
set :deploy_via, :remote_cache
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


#TODO: try this to precompile assets https://gist.github.com/1477596

# If you are using Passenger mod_rails uncomment this:
 namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
 end

namespace :deploy do
  task :ln_assets do
    run <<-CMD
      rm -rf #{latest_release}/public/assets &&
      mkdir -p #{shared_path}/assets &&
      ln -s #{shared_path}/assets #{latest_release}/public/assets
    CMD
  end

  task :assets do
    update_code
    ln_assets
    
    run_locally "rake assets:precompile"
    run_locally "cd public; tar -zcvf assets.tar.gz assets"
    top.upload "public/assets.tar.gz", "#{shared_path}", :via => :scp
    run "cd #{shared_path}; tar -zxvf assets.tar.gz"
    run_locally "rm public/assets.tar.gz"
    run_locally "rm -rf public/assets"
    
    create_symlink
    restart
  end

end
