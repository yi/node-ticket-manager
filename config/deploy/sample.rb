
set :user, "user"
set :host, "127.0.0.1"

set :mode, "development"

role :web, host
role :app, host

# refresh build every deployment
before "deploy", "build:release"

