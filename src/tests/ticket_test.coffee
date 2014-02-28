###
# test for models_ticket
###

## Module dependencies
should = require "should"
_ = require "underscore"
debuglog = require("debug")("ticketman:test:ticket_test")

STATUS = require "../enums/ticket_status"

config = require("../config/config")['development']
mongoose = require('mongoose')
mongoose.connect(config.db)
mongoose.set('debug', true)

require "../models/ticket"

Ticket = mongoose.model('Ticket')

SAMPLE_TITLE_1 = "test models/ticket 1"

SAMPLE_TITLE_2 = "test models/ticket 2"

SAMPLE_CONTENT_1 =
  itema : "is string"
  itemb :
    sub : "content"
    sub2 : "still"
  itemc : [ 1, 2, "three" ]
  itemd : true


## Test cases
describe "test", ->

  after (done)->
    mongoose.connection.db.dropCollection 'tickets', done

  describe "models/ticket", ->

    it "should able create doc", (done) ->

      ticket = new Ticket
        title : SAMPLE_TITLE_1
        owner_id : 'test'
        category : 'test'
        content : SAMPLE_CONTENT_1
      ticket.save (err)->
        should.not.exist err

        ticket = new Ticket
          title : SAMPLE_TITLE_2
          owner_id : 'test'
          category : 'test'
          content : SAMPLE_CONTENT_1
        ticket.save (err)->
          should.not.exist err
          done()

    it "should not allow alive ticket with duplicated title", (done) ->
      ticket = new Ticket
        title : SAMPLE_TITLE_1
        owner_id : 'test'
        category : 'test'
        content : SAMPLE_CONTENT_1
      ticket.save (err)->
        debuglog "[models_ticket_test] err:#{err}"
        should.exist err
        done()

    it "should able to complete ticket", (done)->
      Ticket.changeStatus {title:SAMPLE_TITLE_1}, STATUS.COMPLETE, (err, ticket)->
      #Ticket.findOneAndUpdate {title:SAMPLE_TITLE_1}, {status: STATUS.COMPLETE}, (err, ticket)->
        debuglog "[models_ticket_test] err:#{err}, ticket:%j", ticket
        should.not.exist err
        should.exist ticket
        ticket.status.should.eql(STATUS.COMPLETE)
        done()

    it "should not abandon a completed ticket", (done)->
      Ticket.changeStatus {title:SAMPLE_TITLE_1}, STATUS.ABANDON, (err, ticket)->
      #Ticket.findOneAndUpdate {title:SAMPLE_TITLE_1}, {status: STATUS.COMPLETE}, (err, ticket)->
        debuglog "[models_ticket_test] err:#{err}, ticket:%j", ticket
        should.not.exist ticket
        done()

    it "should able to process a pending ticket", (done)->
      Ticket.changeStatus {title:SAMPLE_TITLE_2}, STATUS.PROCESSING, (err, ticket)->
        debuglog "[models_ticket_test] err:#{err}, ticket:%j", ticket
        should.not.exist err
        should.exist ticket
        ticket.status.should.eql(STATUS.PROCESSING)
        ticket.title.should.eql(SAMPLE_TITLE_2)
        done()

    it "should able to add comment to a ticket", (done)->
      Ticket.findOne {title:SAMPLE_TITLE_2}, (err, ticket)->
        debuglog "[models_ticket_test] err:#{err}, ticket:%j", ticket
        should.not.exist err
        should.exist ticket
        comment =
          name : "worker"
          kind : "info"
          content : "test comment"
        Ticket.addComment ticket.id, comment, (err, ticket)->
          debuglog "[models_ticket_test] err:#{err}, ticket:%j", ticket
          should.not.exist err
          should.exist ticket
          _.last(ticket.comments).content.should.eql(comment.content)
          done()

    it "arrange nothing when no avaliable ticket", (done)->

      workerOptions =
        worker : "assignment worker"
        category : "assignment"

      Ticket.arrangeAssignment workerOptions, (err, ticket)->
        debuglog "[models_ticket_test] err:#{err}, ticket:%j", ticket
        should.not.exist err
        should.not.exist ticket
        done()

    it "arrange assignment", (done)->

      ticket = new Ticket
        title : "for assignment 01"
        owner_id : 'test'
        category : 'assignment'
        content : "for assignment 01"
      ticket.save (err, ticket)->
        debuglog "[models_ticket_test] err:#{err}, ticket:%j", ticket
        should.not.exist err

        ticket = new Ticket
          title : "for assignment 02"
          owner_id : 'test'
          category : 'assignment'
          content : "for assignment 02"
        ticket.save (err, ticket)->
          debuglog "[models_ticket_test] err:#{err}, ticket:%j", ticket
          should.not.exist err

          ticket = new Ticket
            title : "for assignment 03"
            owner_id : 'test'
            category : 'assignment'
            content : "for assignment 03"
          ticket.save (err, ticket)->
            debuglog "[models_ticket_test] err:#{err}, ticket:%j", ticket
            should.not.exist err
            workerOptions =
              worker : "assignment worker"
              category : "assignment"
            Ticket.arrangeAssignment workerOptions, (err, ticket)->
              debuglog "[models_ticket_test] err:#{err}, ticket:%j", ticket
              should.not.exist err
              should.exist ticket
              ticket.status.should.eql STATUS.PROCESSING
              ticket.title.should.eql "for assignment 01"
              done()


    it "always arrange eldest assignment", (done)->

      workerOptions =
        worker : "assignment worker"
        category : "assignment"

      Ticket.arrangeAssignment workerOptions, (err, ticket)->
        debuglog "[models_ticket_test] err:#{err}, ticket:%j", ticket
        should.not.exist err
        should.exist ticket
        ticket.title.should.eql "for assignment 02"
        ticket.status.should.eql STATUS.PROCESSING
        done()




