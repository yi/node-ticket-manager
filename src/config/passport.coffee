
mongoose = require('mongoose')
LocalStrategy = require('passport-local').Strategy
TwitterStrategy = require('passport-twitter').Strategy
FacebookStrategy = require('passport-facebook').Strategy
GitHubStrategy = require('passport-github').Strategy
GoogleStrategy = require('passport-google-oauth').OAuth2Strategy
User = mongoose.model('User')


module.exports = (passport, config)->
  # require('./initializer')

  # serialize sessions
  passport.serializeUser (user, done)-> done(null, user.id)

  passport.deserializeUser (id, done)->
    User.findOne({ _id: id }, (err, user)-> done(err, user))

  # use local strategy
  localStrategyConfig =
    usernameField: 'email',
    passwordField: 'password'

  localStrategyCallback = (email, password, done)->
    User.findOne { email: email }, (err, user)->
      return done(err) if (err)
      return done(null, false, { message: 'Unknown user' }) unless user
      return done(null, false, { message: 'Invalid password' }) unless user.authenticate(password)
      return done(null, user)
    return

  passport.use new LocalStrategy localStrategyConfig, localStrategyCallback

  # use twitter strategy
  #twitterSetting =
    #consumerKey: config.twitter.clientID
    #consumerSecret: config.twitter.clientSecret
    #callbackURL: config.twitter.callbackURL

  twitterStrategyConfig =
    consumerKey: config.twitter.clientID
    consumerSecret: config.twitter.clientSecret
    callbackURL: config.twitter.callbackURL

  twitterStrategyCallback = (token, tokenSecret, profile, done)->
    User.findOne {'twitter.id': profile.id }, (err, user)->
      return done(err) if err
      unless user
        user = new User
          name: profile.displayName
          username: profile.username
          provider: 'twitter'
          twitter: profile._json

        user.save (err)->
          if err? then console.log err
          return done(err, user)
      else
        return done(err, user)
      return
    return

  passport.use new TwitterStrategy twitterStrategyConfig, twitterStrategyCallback

  # use facebook strategy
  facebookStrategyConfig =
    clientID: config.facebook.clientID
    clientSecret: config.facebook.clientSecret
    callbackURL: config.facebook.callbackURL

  facebookStrategyCallback = (accessToken, refreshToken, profile, done)->
    User.findOne {'facebook.id': profile.id }, (err, user)->
      return done(err) if err
      unless user
        user = new User
          name: profile.displayName
          email: profile.emails[0].value
          username: profile.username
          provider: 'facebook'
          facebook: profile._json
        user.save (err) ->
          if err? then console.log err
          return done(err, user)
      else
        return done(err, user)
      return
    return

  passport.use new FacebookStrategy facebookStrategyConfig, facebookStrategyCallback

  # use github strategy
  gitHubStrategyConfig =
    clientID: config.github.clientID
    clientSecret: config.github.clientSecret
    callbackURL: config.github.callbackUR

  gitHubStrategyCallback = (accessToken, refreshToken, profile, done)->
    User.findOne { 'github.id': profile.id }, (err, user)->
      return done(err) if err
      unless user
        user = new User
          name: profile.displayName
          email: profile.emails[0].value
          username: profile.username
          provider: 'github'
          github: profile._json
        user.save (err) ->
          if err? then console.log err
          return done(err, user)
      else
        return done(err, user)
      return
    return

  passport.use new GitHubStrategy gitHubStrategyConfig, gitHubStrategyCallback

  # use google strategy
  googleStrategyConfig =
    clientID: config.google.clientID
    clientSecret: config.google.clientSecret
    callbackURL: config.google.callbackURL

  googleStrategyCallback = (accessToken, refreshToken, profile, done)->
    User.findOne {'google.id': profile.id}, (err, user)->
      unless user
        # make a new google profile without key start with $
        new_profile = {}
        new_profile.id = profile.id
        new_profile.displayName = profile.displayName
        new_profile.emails = profile.emails
        user = new User
          name: profile.displayName
          email: profile.emails[0].value
          username: profile.username
          provider: 'google'
          google: new_profile._json

        user.save (err)->
          if err? then console.log err
          return done(err, user)
      else
        return done(err, user)
      return
    return

  passport.use new GoogleStrategy googleStrategyConfig, googleStrategyCallback


