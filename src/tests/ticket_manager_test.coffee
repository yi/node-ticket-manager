###
# test for ticket_manager
###

## Module dependencies
should = require "should"
{TicketManager} = require "../"
debuglog = require("debug")("ticketman:test:ticket_manager_test")

ticketManager = new TicketManager("test ticket_manager", "http://localhost:3456")

## Test cases
describe "test ticket_manager", ->

  before () ->

  describe "issue", ->

    it "ticket", (done) ->
      content =
        detailed : "content of ticket",
        mixed : ["data"]

      title = "test ticket #{Date.now()}"
      category = "sample"
      ticketManager.issue title, category, content, (err, ticket)->
        debuglog "err:#{err}, ticket:%j",  ticket
        should.not.exist err
        should.exist ticket
        ticket.title.should.eql title
        ticket.category.should.eql category
        should.exist ticket.id

        ticketManager.issue title, category, content, (err, ticket)->
          debuglog "err:#{err}, ticket:%j",  ticket
          should.exist err
          should.not.exist ticket
          done()


