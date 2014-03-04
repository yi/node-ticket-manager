###
# nodejs-express-mongoose-demo
# Copyright(c) 2013 Madhusudhan Srinivasa <madhums8@gmail.com>
# MIT Licensed
###

## Module dependencies.

express = require('express')
fs = require('fs')
p = require "commander"
path = require "path"
_ = require "underscore"
debuglog = require("debug")("ticketman:server")

pkg = JSON.parse(fs.readFileSync(path.join(__dirname, "../package.json")))

# config cli
p.version(pkg.version)
  .option('-c, --config [VALUE]', 'path to config file')
  .option('-p, --port [VALUE]', 'port to run this web service')
  .option('-e, --environment  [VALUE]', 'application environment mode')
  .parse(process.argv)

# Main application entry file.
# Please note that the order of loading is important.

# Load configurations
# if test env, load example file
env = p.environment || process.env.NODE_ENV || 'development'
configs = require('./config/config')
config = configs[env]

config.version = pkg.version
# fix root path error after distillation
config.root = path.resolve __dirname, "../"
debuglog "[server] config.root:#{config.root}"

# load and mixin external configurations
if p.config
  try
    pathToExternalConfig = path.resolve(config.root, p.config)
    debuglog "pathToExternalConfig:#{pathToExternalConfig}"
    externalConfig = JSON.parse(fs.readFileSync(pathToExternalConfig))
    debuglog "externalConfig:%j", externalConfig
    _.extend config, externalConfig
  catch err
    debuglog "ERROR [server] fail to mixin externalConfig. #{err}"


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
port = p.port || process.env.PORT || 3456
app.listen(port)
debuglog "Ticketman app started on port #{port}"

# expose app
exports = module.exports = app

