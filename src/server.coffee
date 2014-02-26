###
# nodejs-express-mongoose-demo
# Copyright(c) 2013 Madhusudhan Srinivasa <madhums8@gmail.com>
# MIT Licensed
###

## Module dependencies.

express = require('express')
fs = require('fs')

# Main application entry file.
# Please note that the order of loading is important.

# Load configurations
# if test env, load example file
env = process.env.NODE_ENV || 'development'
config = require('./config/config')[env]

mongoose = require('mongoose')

# Bootstrap db connection
mongoose.connect(config.db)

# Bootstrap models
require "./models/ticket"

# bootstrap passport config
#require('./config/passport')(passport, config)

app = express()
# express settings
#require('./config/express')(app, config, passport)
require('./config/express')(app, config)

# Bootstrap routes
#require('./config/routes')(app, passport, auth)
require('./config/routes')(app)

# Start the app by listening on <port>
port = process.env.PORT || 3456
app.listen(port)
console.log "Ticket System app started on port #{port}"

# expose app
exports = module.exports = app

