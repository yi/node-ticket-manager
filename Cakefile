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

