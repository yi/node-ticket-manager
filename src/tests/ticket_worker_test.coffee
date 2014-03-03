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

TicketManager = require "../ticket_manager"

ticketManager = new TicketManager("test ticket_manager", "http://localhost:3456")

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
      WORKER_RECORD.interval = 300
      WORKER_RECORD.timeout = 10000

      ticketWorker = new TicketWorker(WORKER_RECORD)
      done()

  describe "ticket_worker", ->

    @timeout 30 * 1000

    it "live cycle", (done)->

      ticketWorker.on "timeout", ()->
        debuglog "ticketWorker.on 'timeout'"
        done()

      ticketWorker.on "new ticket", (ticket)->
        debuglog "ticketWorker.on 'new ticket', ticket:%j", ticket
        ticketWorker.isBusy().should.be.ok

      ticketWorker.on "timeout", (ticket)->
        debuglog "ticketWorker.on 'timeout', ticket:%j", ticket
        ticketWorker.isBusy().should.not.be.ok

      # ticket should be idle by default
      ticketWorker.isBusy().should.not.be.ok

      ticketManager.issue "test ticket worker #{Date.now()}", "sample", {some:"content"}, (err, ticket)->
        debuglog "err:#{err}, ticket:%j",  ticket
        should.not.exist err
        should.exist ticket


