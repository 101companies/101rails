 require 'bundler/capistrano'
 load 'deploy/assets'

logger.level = Logger::DEBUG

set :application, "101wiki"
set :repository, "git://github.com/101companies/101rails.git"  # Your clone URL
set :branch, "master"

set :rake, "#{rake} --trace"

set :scm, :git
#set :scm_command, "/usr/local/bin/git"
#set :local_scm_command, "/usr/local/bin/git"

# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "101companies.org"                          # Your HTTP server, Apache/etc
role :app, "101companies.org"                          # This may be the same as your `Web` server
role :db,  "101companies.org", :primary => true # This is where Rails migrations will run

set :user, "user101"
set :host, '101companies.org'

default_run_options[:pty] = true  # Must be set for the password prompt
                                  # from git to work
set :use_sudo, true
set :user, "user101"

set :deploy_to, "/home/user101/wiki"
set :deploy_via, :remote_cache
ssh_options[:forward_agent] = true
ssh_options[:keys] = [File.join(ENV["HOME"], ".ssh", "id_rsa")] 

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:assets", "deploy:restart", "deploy:cleanup"

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

namespace :assets do
  task :precompile, :roles => :web, :except => { :no_release => true } do
    # Check if assets have changed. If not, don't run the precompile task - it takes a long time.
    force_compile = false
    changed_asset_count = 0
    begin
      from = source.next_revision(current_revision)
      asset_locations = 'app/assets/ lib/assets vendor/assets'
      changed_asset_count = capture("cd #{latest_release} && #{source.local.log(from)} #{asset_locations} | wc -l").to_i
    rescue Exception => e
      logger.info "Error: #{e}, forcing precompile"
      force_compile = false
    end
    if changed_asset_count > 0 || force_compile
      logger.info "#{changed_asset_count} assets have changed. Pre-compiling"
      run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
    else
      logger.info "#{changed_asset_count} assets have changed. Skipping asset pre-compilation"
    end
  end
end
