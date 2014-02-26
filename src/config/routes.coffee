
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
  app.get '/', controller.list





