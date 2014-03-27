
set :user, "user"
set :host, "127.0.0.1"

set :mode, "development"

set :deploy_to, '/var/www/apps/ticketman'

set :path_to_log, "#{current_path}/log/#{application}.log"
set :path_to_pid, "#{current_path}/#{application}.pid"
set :path_to_main_script, "#{current_path}/lib/server.min.js"

role :web, host
role :app, host

# refresh build every deployment
before "deploy", "build:release"

