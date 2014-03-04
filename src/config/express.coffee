# Module dependencies.

express = require('express')
mongoStore = require('connect-mongo')(express)
flash = require('connect-flash')
path = require "path"
view_helper = require "../utils/view_helper"

module.exports = (app, config, passport)->

  app.set('showStackError', true)
  # should be placed before express.static
  app.use(express.compress({
    filter: (req, res)-> return /json|text|javascript|css/.test(res.getHeader('Content-Type'))
    level: 9
  }))
  app.use(express.static(config.root + '/public'))

  # don't use logger for test env
  app.use(express.logger('dev')) if (process.env.NODE_ENV isnt 'test')

  app.use(express.basicAuth(config.basicAuth.username, config.basicAuth.password))

  # set views path, template engine and default layout
  pathToView = path.join config.root, '/views'
  console.log "[express::main] pathToView:#{pathToView}"

  app.set 'views', config.root + '/views'
  app.set 'view engine', 'jade'

  app.configure ()->
    # dynamic helpers
    #app.use(helpers(config.app.name))

    # cookieParser should be above session
    #app.use(express.cookieParser())

    # bodyParser should be above methodOverride
    app.use(express.bodyParser())
    app.use(express.methodOverride())

    # express/mongo session storage
    #app.use(express.session({
      #secret: 'fasr_42*@3paskr$2LQRkvQ',
      #store: new mongoStore({
        #url: config.db,
        #collection : 'sessions'
      #})
    #}))

    # connect flash for flash messages
    #app.use(flash())

    # use passport session
    #app.use(passport.initialize())
    #app.use(passport.session())

    # routes should be at the last
    app.use(app.router)

    # assume "not found" in the error msgs
    # is a 404. this is somewhat silly, but
    # valid, you can do whatever you like, set
    # properties, use instanceof etc.
    app.use (err, req, res, next)->
      # treat as 404
      return next() if (~err.message.indexOf('not found'))

      # log it
      console.error(err.stack)

      # error page
      res.status(500).render('500', { error: err.stack })

    # assume 404 since no middleware responded
    app.use (req, res, next)->
      res.status(404).render('404', { url: req.originalUrl, error: 'Not found' })

    # 向每个view render 注入本地数据
    app.locals
      VERSION : config.version
      APP_NAME : config.app.name
      helper : view_helper

