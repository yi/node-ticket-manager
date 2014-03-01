###
# test for ticket_worker
###

## Module dependencies
should = require "should"

request = require "request"

TicketWorker = require "../ticket_worker"
TicketManager = require "../ticket_manager"

debuglog = require("debug")("ticketman:test:ticket_worker_test")
assert = require "assert"

config = require("../config/config")['development']

WORKER_RECORD = null

ticketWorker  = null

setTicketWorker = (val)-> ticketWorker = val

ticketManager = new TicketManager("test ticket_manager", "http://localhost:3456")

HOST = "http://localhost:3456"
## Test cases
describe "test ticket_worker", ->

  before (done) ->

    options =
      method: 'POST'
      url: "#{HOST}/workers/new.json"
      auth : config.basicAuth
      json :
        name: "test##{Date.now().toString(36)}"
        desc: "just for test"

    request options, (err, res, body)->
      debuglog "err:#{err}, res.statusCode:#{res.statusCode}, body:%j", body
      assert.equal err, null
      assert.equal  res.statusCode, 200
      assert.notEqual body, null
      body.id = body._id
      WORKER_RECORD = body
      WORKER_RECORD.host = HOST
      WORKER_RECORD.basicAuth = config.basicAuth
      WORKER_RECORD.category = "sample"

      ticketWorker = new TicketWorker(WORKER_RECORD)
      done()

  describe "ticket_worker", ->

    it "requireTicket when no pending ticket", (done)->
      ticketWorker.requireTicket (err, ticket)->
        should.not.exist err
        should.not.exist ticket
        done()


    it "requireTicket when pending ticket available", (done)->
      ticketManager.issue "test ticket@#{Date.now()}", "sample", {content:"not null"}, (err, originTicket)->
        debuglog "err:#{err}, originTicket:%j", originTicket

        should.not.exist err
        should.exist originTicket

        ticketWorker.on "new ticket", (ticket)->
          debuglog "on new ticket: ticket:%j", ticket
          should.exist ticket
          ticket.title.should.eql originTicket.title
          done()

        ticketWorker.requireTicket (err, ticket)->
          debuglog "requireTicket: ticket:%j", ticket
          should.not.exist err
          should.exist ticket
          ticket.title.should.eql originTicket.title

