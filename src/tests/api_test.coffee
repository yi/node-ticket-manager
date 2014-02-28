###
# test for api
###

## Module dependencies
should = require "should"
request = require "request"
config = require("../config/config")['development']

HOST = "http://localhost:3456"

TIMESTAMP = Date.now()

TICKET_HELD_BY_WORKER = null

## Test cases
describe "test api", ->

  before () ->
    # before test happen

  describe "/api/tickets/new", ->
    path = "/api/tickets/new"

    it "should create ticket", (done) ->
      title = "title of ticket #{TIMESTAMP}"
      owner = "admin"
      options =
        method: 'POST'
        url: "#{HOST}#{path}"
        auth : config.basicAuth
        json :
          title : title
          owner_id : owner
          category : "test api"
          content :
            detailed : "content of ticket",
            mixed : ["data"]

      request options, (err, res, body)->
        #console.log "[api_test] \n\t\terr:%j \n\t\tres:%j \n\t\tbody:%j", err, res, body

        should.not.exist err
        should.exist res
        res.statusCode.should.eql 200
        should.exist body
        body.title.should.eql title
        body.owner_id.should.eql owner
        done()


    it "fail to create duplicate ticket", (done) ->
      title = "title of ticket #{TIMESTAMP}"
      owner = "admin"
      options =
        method: 'POST'
        auth : config.basicAuth
        url: "#{HOST}#{path}"
        json :
          title : title
          owner_id : owner
          category : "test api"
          content :
            detailed : "content of ticket",
            mixed : ["data"]

      request options, (err, res, body)->
        console.log "[api_test] \n\t\terr:%j \n\t\tres:%j \n\t\tbody:%j", err, res.statusCode, body

        should.not.exist err
        should.exist res
        res.statusCode.should.not.eql 200
        done()

  describe "/api/tickets/assign", ->
    path = "/api/tickets/assign"
    it "assign ticket to worker", (done)->
      options =
        method: 'PUT'
        auth : config.basicAuth
        url: "#{HOST}#{path}"
        json :
          worker : "test worker"
          category : "test api"

      request options, (err, res, ticket)->
        console.log "[api_test] \n\t\terr:%j \n\t\tres:%j \n\t\tbody:%j", err, res.statusCode, ticket

        should.not.exist err
        should.exist res
        res.statusCode.should.eql 200
        TICKET_HELD_BY_WORKER = ticket
        done()

  describe '/api/tickets/:id/comment', ->
    it "add comment to ticket", (done)->

      options =
        method: 'PUT'
        auth : config.basicAuth
        url: "#{HOST}/api/tickets/#{TICKET_HELD_BY_WORKER._id}/comment"
        json :
          name : "worker",
          kind : "info",
          content : "test info comment"

      request options, (err, res, ticket)->
        console.log "[api_test] \n\t\terr:%j \n\t\tres:%j \n\t\tbody:%j", err, res.statusCode, ticket
        should.not.exist err
        res.statusCode.should.eql 200

        options.json.kind = "warning"
        options.json.content = "test warning comment"
        request options, (err, res, ticket)->
          console.log "[api_test] \n\t\terr:%j \n\t\tres:%j \n\t\tbody:%j", err, res.statusCode, ticket
          should.not.exist err
          res.statusCode.should.eql 200
          done()


  describe '/api/tickets/:id/complete', ->
    it "complete a task", (done)->
      options =
        method: 'PUT'
        auth : config.basicAuth
        url: "#{HOST}/api/tickets/#{TICKET_HELD_BY_WORKER._id}/complete"
        json :
          name : "worker",

      request options, (err, res, ticket)->
        should.not.exist err
        res.statusCode.should.eql 200
        done()


  describe '/api/tickets/:id/giveup', ->
    it "giveup a task", (done)->
      options =
        method: 'POST'
        auth : config.basicAuth
        url: "#{HOST}/api/tickets/new"
        json :
          title :  "title of ticket #{TIMESTAMP} - 2"
          owner_id :  "admin"
          category : "test api"
          content :
            detailed : "content of ticket",
            mixed : ["data"]

      request options, (err, res, ticket)->
        should.not.exist err
        res.statusCode.should.eql 200

        options =
          method: 'PUT'
          url: "#{HOST}/api/tickets/#{ticket._id}/giveup"
          auth : config.basicAuth
          json :
            name : "worker",

        request options, (err, res, ticket)->
          should.not.exist err
          res.statusCode.should.eql 200
          done()





