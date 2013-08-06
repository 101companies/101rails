require 'bundler/capistrano'
require 'yaml'
require 'pathname'
load 'deploy/assets'
require "delayed/recipes"

#added for delayed job
set :rails_env, "production"
after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:restart"

set :sync_backups, 3
set :db_file, "mongoid.yml"

# keep 10 last revisions of app
set :keep_releases, 10
# automatically remove old revisions, except last 10, after deploy
after "deploy:update", "deploy:cleanup"

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

namespace :sync do
  namespace :down do
       task :db, :roles => :db, :only => { :primary => true } do
        filename = "database.production.#{Time.now.strftime '%Y-%m-%d_%H-%M-%S'}.sql.bz2"
        on_rollback { delete "#{shared_path}/sync/#{filename}" }
        username, password, database, host = database_config('production')
        production_database = database

        run "mongodump -db #{database}"
        run "tar -cjf /home/user101/#{filename} dump/#{database}"
        run "rm -rf dump"

        download "/home/user101/#{filename}", "tmp/#{filename}"

        username, password, database = database_config('development')
        system "tar -xjvf tmp/#{filename}"

        system "mongorestore #{fetch(:db_drop, '')} -db #{database} dump/#{production_database}"

        system "rm -f tmp/#{filename} | rm -rf dump"

        logger.important "sync database from the 'production' to local finished"
    end
  end
end

#
# Reads the database credentials from the local config/database.yml file
# +db+ the name of the environment to get the credentials for
# Returns username, password, database
#
def database_config(db)
  database = YAML::load_file('config/mongoid.yml')
  return database["#{db}"]['sessions']['default']['username'],
         database["#{db}"]['sessions']['default']['password'],
         database["#{db}"]['sessions']['default']['database'],
         database["#{db}"]['sessions']['default']['host']
end


#
# Reads the database credentials from the remote config/database.yml file
# +db+ the name of the environment to get the credentials for
# Returns username, password, database
#
def remote_database_config(db)
  remote_config = capture("cat #{shared_path}/config/#{fetch(:db_file, 'mongoid.yml')}")
  database = YAML::load(remote_config)
  return database["#{db}"]['username'], database["#{db}"]['password'], database["#{db}"]['database'], database["#{db}"]['host']
end

#
# Returns the actual host name to sync and port
#
def host_and_port
  return roles[:web].servers.first.host, ssh_options[:port] || roles[:web].servers.first.port || 22
end
