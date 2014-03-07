###
# test for ticket_worker
###

## Module dependencies
should = require "should"

request = require "request"

{TicketWorker} = require "../"

debuglog = require("debug")("ticketman:test:ticket_worker_test")
assert = require "assert"

config = require("../config/config")['development']

WORKER_RECORD = null

{TicketManager} = require "../"

ticketManager = new TicketManager("test ticket_manager", "http://localhost:3456")

ticketWorker  = null

setTicketWorker = (val)-> ticketWorker = val

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
      debuglog "err:#{err}, res.statusCode:#{if res? then res.statusCode else "n/a"}, body:%j", body
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


  beforeEach ()->
    ticketWorker.removeAllListeners()

  afterEach ()->
    ticketWorker.removeAllListeners()


  describe "ticket_worker", ->

    @timeout 30 * 1000

    it "live cycle for timeout", (done)->

      ticketWorker.on "giveup", ()->
        debuglog "ticketWorker.on 'giveup'"
        ticketWorker.removeAllListeners()
        done()

      ticketWorker.on "complete", ()->
        debuglog "ticketWorker.on 'complete'"
        throw new Error "this should not hasppen, ticketWorker.on 'complete'"

      ticketWorker.on "new ticket", (ticket)->
        debuglog "ticketWorker.on 'new ticket', ticket:%j", ticket
        should.exist ticket
        ticketWorker.isBusy().should.be.ok

        setTimeout (()-> ticketWorker.update("test update 1")), 1000
        setTimeout (()-> ticketWorker.update("test update 2", "info")), 2000
        setTimeout (()-> ticketWorker.update("test update 3", "warning")), 3000
        setTimeout (()-> ticketWorker.update("test update 4", "danger")), 4000
        setTimeout (()-> ticketWorker.update("test update 5", "success")), 5000

      # ticket should be idle by default
      ticketWorker.isBusy().should.not.be.ok

      ticketManager.issue "test ticket worker #{Date.now()}", "sample", {some:"content"}, (err, ticket)->
        debuglog "err:#{err}, ticket:%j",  ticket
        should.not.exist err
        should.exist ticket


    it "live cycle for completion", (done)->

      ticketWorker.on "complete", ()->
        debuglog "ticketWorker.on 'complete'"
        ticketWorker.removeAllListeners()
        done()

      ticketWorker.on "timeout", ()->
        debuglog "ticketWorker.on 'timeout'"
        throw new Error "this should not hasppen, ticketWorker.on 'timeout'"

      ticketWorker.on "new ticket", (ticket)->
        debuglog "ticketWorker.on 'new ticket', ticket:%j", ticket
        should.exist ticket
        ticketWorker.isBusy().should.be.ok

        setTimeout (()-> ticketWorker.complete()), 2000

      ticketManager.issue "test ticket worker #{Date.now()}", "sample", {some:"content"}, (err, ticket)->
        debuglog "err:#{err}, ticket:%j",  ticket
        should.not.exist err
        should.exist ticket


    it "live cycle for giveup", (done)->

      ticketWorker.on "giveup", ()->
        debuglog "ticketWorker.on 'giveup'"
        ticketWorker.removeAllListeners()
        done()

      ticketWorker.on "complete", ()->
        debuglog "ticketWorker.on 'complete'"
        throw new Error "this should not hasppen, ticketWorker.on 'complete'"

      ticketWorker.on "timeout", ()->
        debuglog "ticketWorker.on 'timeout'"
        throw new Error "this should not hasppen, ticketWorker.on 'timeout'"

      ticketWorker.on "new ticket", (ticket)->
        debuglog "ticketWorker.on 'new ticket', ticket:%j", ticket
        should.exist ticket
        ticketWorker.isBusy().should.be.ok

        setTimeout (()-> ticketWorker.giveup("give up for some reason")), 2000

      ticketManager.issue "test ticket worker #{Date.now()}", "sample", {some:"content"}, (err, ticket)->
        debuglog "err:#{err}, ticket:%j",  ticket
        should.not.exist err
        should.exist ticket




