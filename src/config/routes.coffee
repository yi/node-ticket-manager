m = require "../middleware"

module.exports = (app, passport, auth)->

  # user routes
  #users = require "../controllers/users"
  #app.get '/login', users.login
  #app.get '/signup', users.signup
  #app.get '/logout', users.logout
  #app.post '/users', users.create
  #app.post '/users/session', passport.authenticate('local', {failureRedirect: '/login', failureFlash: 'Invalid email or password.'}), users.session
  #app.get '/users/:userId', users.show

  # this is home page
  controller = require "../controllers/ticket"
  app.get '/', controller.index
  app.get '/tickets', controller.index
  app.get '/tickets/list.json', controller.list
  app.get '/tickets/count.json', controller.count
  app.get '/tickets/:id', controller.show
  app.post '/tickets/:id/abandon', controller.abandon
  app.post '/tickets/:id/giveup', controller.giveup
  app.post '/tickets/:id/comment', controller.adminComment

  app.post '/api/tickets/new', controller.create

  app.put '/api/tickets/assign', m.authWorker, controller.assign
  app.put '/api/tickets/:id/comment', m.authWorker, controller.comment
  app.put '/api/tickets/:id/complete', m.authWorker, controller.complete
  app.put '/api/tickets/:id/giveup', m.authWorker,  controller.giveup


  controller = require "../controllers/worker"
  app.get '/workers.:format?', controller.index
  app.post '/workers/new.:format?', controller.create


