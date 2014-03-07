###
# test for mock_tickets
###

## Module dependencies
should = require "should"

{TicketManager} = require "../"

debuglog = require("debug")("ticketman:test:ticket_manager_test")

config = require("../config/config")['development']

request = require "request"

async = require "async"

ticketManager = new TicketManager("test ticket_manager", "http://localhost:3456")
## Test cases

describe "mock ", ->

  @timeout(10*60*1000)

  it "should mock 100 tickets", (done) ->
    content =
      detailed : "content of ticket",
      mixed : ["data"]

    arr = []
    for i in [0..100]
      arr.push i

    iterator = (item, callback)->
      now = Date.now()
      ticketManager.issue "mock ticket #{now.toString(36)}-#{item}", ((now >> 8).toString(36)), content, callback

    async.each arr, iterator, done



