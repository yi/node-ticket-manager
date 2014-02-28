

env = process.env.NODE_ENV || 'development'
DEFAULT_BASIC_AUTH = require('./config/config')[env]['basicAuth']

request = require "request"

PATH = "/api/tickets/new"

class TicketManager

  constructor: (@name, @host, basicAuth) ->
    @basicAuth = basicAuth || DEFAULT_BASIC_AUTH

  # issue a new ticket
  issue : (title, category, content, callback)->
    options =
      method: 'POST'
      url: "#{@host}#{PATH}"
      auth : @basicAuth
      json :
        title : title
        owner_id : @name
        category : category
        content : content

    request options, (err, res, body)->
      return callback err if err?
      unless res.statusCode is 200
        return callback(new Error("fail to issue ticket:#{title}##{category}. server reponse:#{res.statusCode}"))
      body.id = body._id if body._id?
      callback null, body
      return


module.exports=TicketManager

