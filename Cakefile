###
Cakefile for developping

License: MIT License

Features:
  - Compile CoffeeScript files to JavaScript files
  - Compile LESS files to CSS files
  - Join CoffeeScript files to a single JavaScript file
  - Join CSS files to a single CSS file
  - Minify a single compiled JavaScript file via YUI compressor
  - Minify a single compiled CSS file via YUI compressor
  - Test CoffeeScript files via mocha

Copyright(c) 2012, hashnote.net Alisue allright reserved.
###

# --- CONFIGURE ---------------------------------------------------
PATH_TO_TEST_SRC = "src/tests/"

TEMPLATE_TEST = '
###\n
# test for #{name} \n
###\n
\n
## Module dependencies\n
should = require "should"\n
#{name} = require "../#{name}"\n
\n
## Test cases\n
describe "test #{name}", ->\n
\n
  before () ->\n
    # before test happen\n
\n
  describe "#{name}", ->\n
\n
    it "should", () ->\n
\n
  '

LOG_NAME_TAG_ERROR = "\u001b[31mERROR\u001b[0m -"
LOG_NAME_TAG_WARN = "\u001b[33mWARNING\u001b[0m -"
LOG_NAME_TAG_INFO = "\u001b[32mSUCCESS\u001b[0m -"

# -----------------------------------------------------------------

fs              = require 'fs'
path            = require 'path'
util            = require 'util'
{exec, spawn}   = require 'child_process'
{print} = require 'util'
{spawn, exec} = require 'child_process'

bold = '\\033[0;1m'
green = '\\033[0;32m'
reset = '\\033[0m'
red = '\\033[0;31m'

task 'generate:test', 'Generate a mocha test file', (opts) ->
  name = process.argv[3..][0]

  unless name
    console.error "#{LOG_NAME_TAG_ERROR} missing test name"
    process.exit(1)
    return

  targetFileName = "#{__dirname}/#{PATH_TO_TEST_SRC}#{name}_test.coffee"

  if fs.existsSync(targetFileName)
    console.error "#{LOG_NAME_TAG_ERROR} test file #{targetFileName} already exists!"
    process.exit(1)
    return

  content = TEMPLATE_TEST.replace(/\#\{name\}/g, name)

  fs.writeFileSync(targetFileName, content)
  console.log "#{LOG_NAME_TAG_INFO} generate test file #{targetFileName}."
  process.exit(0)
  return


walk = (dir, done) ->
  results = []
  fs.readdir dir, (err, list) ->
    return done(err, []) if err
    pending = list.length
    return done(null, results) unless pending
    for name in list
      file = "#{dir}/#{name}"
      try
        stat = fs.statSync file
      catch err
        stat = null
      if stat?.isDirectory()
        walk file, (err, res) ->
          results.push name for name in res
          done(null, results) unless --pending
      else
        results.push file
        done(null, results) unless --pending

log = (message, color, explanation) -> console.log color + message + reset + ' ' + (explanation or '')

launch = (cmd, options=[], callback) ->
  app = spawn cmd, options
  app.stdout.pipe(process.stdout)
  app.stderr.pipe(process.stderr)
  app.on 'exit', (status) -> callback?() if status is 0


build = (watch, callback) ->
  if typeof watch is 'function'
    callback = watch
    watch = false

  options = ['-c', '-b', '-o', 'public/js', 'public_src/js']
  options.unshift '-w' if watch
  launch 'coffee', options, callback


mocha = (options, callback) ->
  if typeof options is 'function'
    callback = options
    options = []

  launch 'mocha', options, callback

docco = (callback) ->
  walk 'src', (err, files) -> launch 'docco', files, callback

task 'generate:docs', 'generate documentation', -> docco()

task 'coffee:build', 'compile source', -> build -> log ":)", green

task 'coffee:watch', 'compile source', -> build true

task 'test', 'run tests', -> build -> mocha -> log ":)", green


















