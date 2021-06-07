# typed: false
require 'mina/rails'
require 'mina/git'
# require 'mina/rbenv'  # for rbenv support. (https://rbenv.org)
require 'mina/rvm' # for rvm support. (https://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

set :application_name, '101rails'
set :domain, '101wiki.softlang.org'
set :deploy_to, '/home/ubuntu/101rails'
set :repository, 'https://github.com/101companies/101rails.git'
set :branch, 'master'

# rails 6 fixes
set :compiled_asset_path, ['public/assets', 'public/packs']
set :asset_dirs, ['vendor/assets/', 'app/assets/', 'app/javascript/']
set :shared_dirs, fetch(:shared_dirs, []).push('log', 'tmp/cache', 'lib/target', *fetch(:compiled_asset_path))

# Optional settings:
set :user, 'ubuntu' # Username in the server to SSH to.
#   set :port, '30000'           # SSH port number.
#   set :forward_agent, true     # SSH forward_agent.

# Shared dirs and files will be symlinked into the app-folder by the 'deploy:link_shared_paths' step.
# Some plugins already add folders to shared_dirs like `mina/rails` add `public/assets`, `vendor/bundle` and many more
# run `mina -d` to see all folders and files already included in `shared_dirs` and `shared_files`
# set :shared_dirs, fetch(:shared_dirs, []).push('public/assets')
# set :shared_files, fetch(:shared_files, []).push('config/database.yml', 'config/secrets.yml')

# This task is the environment that is loaded for all remote run commands, such as
# `mina deploy` or `mina rake`.
task :remote_environment do
  # If you're using rbenv, use this to load the rbenv environment.
  # Be sure to commit your .ruby-version or .rbenv-version to your repository.
  # invoke :'rbenv:load'

  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use', '3.0.1'
end

# Put any custom commands you need to run at setup
# All paths in `shared_dirs` and `shared_paths` will be created on their own.
task :setup do
  # command %{rbenv install 2.3.0 --skip-existing}
end

task :'yarn:install' do
  command %(yarn install --production=true)
end

desc 'Deploys the current version to the server.'
task :deploy do
  # uncomment this line to make sure you pushed your local branch to the remote origin
  # invoke :'git:ensure_pushed'

  run(:local) do
    command "scp puma.service #{fetch(:user)}@#{fetch(:domain)}:#{fetch(:shared_path)}/puma.service"
    command "ssh #{fetch(:user)}@#{fetch(:domain)} sudo mv #{fetch(:shared_path)}/puma.service /etc/systemd/system"

    # command "scp puma.socket #{fetch(:user)}@#{fetch(:domain)}:#{fetch(:shared_path)}/puma.socket"
    # command "ssh #{fetch(:user)}@#{fetch(:domain)} sudo mv #{fetch(:shared_path)}/puma.socket /etc/systemd/system"
  end
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'yarn:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    on :launch do
      in_path(fetch(:current_path)) do
        command %(mkdir -p tmp/)
        command %(sudo systemctl daemon-reload)
        command %(sudo systemctl restart puma.service)
      end
    end
  end

  # you can use `run :local` to run tasks on local machine before of after the deploy scripts
  # run(:local){ say 'done' }
end

# For help in making your deploy script, see the Mina documentation:
#
#  - https://github.com/mina-deploy/mina/tree/master/docs
