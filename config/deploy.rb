# frozen_string_literal: true

require 'capistrano-rvm'
require 'dotenv'
require 'rvm/capistrano'

Dotenv.load('.env')

# config valid for current version and patch releases of Capistrano
lock '~> 3.16.0'

server ENV['SERVER_IP'], port: ENV['SERVER_PORT'], user: ENV['DEPLOY_USER'], roles: %w{app}, primary: true
set :repo_name, ENV['REPO_NAME']

set :repo_url, "git@github.com:#{fetch(:repo_name)}.git"
set :application, 'puma'
set :branch, 'main'
# set :branch, :main
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :rvm_type, :user # Literal ':user'

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

# set :application, 'sinatra'
set :application, 'sinatra-test'
set :repo_url, "git@github.com:#{fetch(:repo_name)}.git"
set :branch, 'main'
set :user, ENV['DEPLOY_USER']
set :puma_threads,    [4, 16]
set :puma_workers,    0

set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/#{fetch(:application)}"
set :puma_bind,       'tcp://0.0.0.0:9292'
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, false # Change to false when not using ActiveRecord
# set :puma_control_app, true
# set :puma_plugins, [:yabeda]  #accept array of plugins
set :linked_dirs, %w[tmp/pids tmp/sockets log]
set :ssh_options,     { forward_agent: true }

puts "#{shared_path}"

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

# namespase :sidekiq do
#   desc ''
# end

namespace :deploy do
  desc 'Make sure local git is in sync with remote.'
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/main`
        puts 'WARNING: HEAD is not the same as origin/main'
        puts 'Run `git push` to sync changes.'
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end
