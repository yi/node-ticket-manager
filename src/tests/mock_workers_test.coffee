###
# test for mock_workers
###

## Module dependencies
should = require "should"

{TicketWorker} = require "../"

debuglog = require("debug")("ticketman:test:ticket_worker_test")

config = require("../config/config")['development']

request = require "request"

async = require "async"

HOST = "http://localhost:3456"

## Test cases

describe "mock ", ->

  @timeout(10*60*1000)

  it "should mock 100 workers", (done) ->

    options =
      method: 'POST'
      url: "#{HOST}/workers/new.json"
      auth : config.basicAuth
      json :
        name: "test-#{Date.now().toString(36)}"
        desc: "just for test"

    arr = []
    for i in [0..100]
      arr.push i

    async.each arr, ((i, cb)-> (options.json.name += i) && request(options, cb)), done



