
set :user, "user"
set :host, "host"

set :mode, "development"

role :web, host
role :app, host

# refresh build every deployment
before "deploy", "build:release"

