
# Module dependencies.

mongoose = require('mongoose')
User = mongoose.model('User')

exports.signin = (req, res)->

# Auth callback
exports.authCallback = (req, res, next)->
  res.redirect('/')
  return

# Show login form
exports.login = (req, res)->
  res.render 'users/login',
    title: 'Login',
    message: req.flash('error')
  return

# Show sign up form
exports.signup = (req, res)->
  res.render 'users/signup',
    title: 'Sign up',
    user: new User()
  return

# Logout
exports.logout = (req, res)->
  req.logout()
  res.redirect('/login')
  return

# Session
exports.session = (req, res)->
  res.redirect('/')
  return

# Create user
exports.create = (req, res)->
  newUser = new User(req.body)
  newUser.provider = 'local'

  User.findOne({ email: newUser.email }).exec (err, user)->
    return next(err) if err?
    unless user?
      newUser.save (err)->
        if err?
          res.render 'users/signup',
            errors: err.errors
            user:newUser
          return

        req.logIn newUser, (err)->
          return next err if err?
          return res.redirect('/')
        return
    else
      res.render 'users/signup',
        errors: [{"type":"email already registered"}]
        user:newUser
      return
    return
  return

#  Show profile
exports.show = (req, res)->
  User.findOne({ _id : req.params['userId'] }).exec (err, user)->
    return next(err) if err?
    return next(new Error('Failed to load User ' + id)) unless user?

    res.render 'users/show',
      title: user.name,
      user: user
    return
  return

# Find user by id
exports.user = (req, res, next, id)->
  User.findOne({ _id : id }).exec (err, user)->
    return next(err) if err?
    return next(new Error('Failed to load User ' + id)) unless user?
    req.profile = user
    next()
    return
  return



