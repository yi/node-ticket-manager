###
# nodejs-express-mongoose-demo
# Copyright(c) 2013 Madhusudhan Srinivasa <madhums8@gmail.com>
# MIT Licensed
###

## Module dependencies.

express = require('express')
fs = require('fs')
p = require "commander"

# Main application entry file.
# Please note that the order of loading is important.

# Load configurations
# if test env, load example file
env = process.env.NODE_ENV || 'development'
config = require('./config/config')[env]

mongoose = require('mongoose')

# Bootstrap db connection
mongoose.connect(config.db)

mongoose.set('debug', true) if env is 'development'

# Bootstrap models
require "./models/ticket"
require "./models/worker"


app = express()

# 启动 express web 框架
require('./config/express')(app, config)

# 启动路由器
require('./config/routes')(app)

# Start the app by listening on <port>
port = process.env.PORT || 3456
app.listen(port)
console.log "Ticketman app started on port #{port}"

# expose app
exports = module.exports = app

