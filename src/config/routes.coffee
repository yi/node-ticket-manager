
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

  app.put '/api/tickets/assign', controller.assign
  app.post '/api/tickets/new', controller.create
  app.put '/api/tickets/:id/comment', controller.comment
  app.put '/api/tickets/:id/complete', controller.complete
  app.put '/api/tickets/:id/giveup', controller.giveup





