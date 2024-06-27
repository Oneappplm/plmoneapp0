# config valid for current version and patch releases of Capistrano
lock "~> 3.19.0"

set :application, "plmoneapp"
set :repo_url, "git@github.com:Oneapp-Dev-Team/#{fetch(:application)}.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name

# list of apps on server
# demo-app - https://demo.plmhealth.net/
# plm-dev - https://dev.plmhealth.net/
# plm-prod - https://plmhealth.net/
# qualifacts - https://qualifacts.plmhealth.net/
set :deploy_to, "/home/deploy/qualifacts" # change demo-app to plm-dev, plm-prod, qualifacts for switching instance

# command
# cap production db:pull - for pulling the database | live to local
# cap production db:push	- for pushing the database | local to live

append :linked_files, 'config/database.yml'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets'

set :keep_releases, 5
set :passenger_restart_with_touch, true

set :copy_exclude, ['.git']
set :branch, :staging

# set :db_local_clean, true

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "tmp/webpacker", "public/system", "vendor", "storage"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
