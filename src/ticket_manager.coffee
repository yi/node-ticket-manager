
assert = require "assert"

debuglog = require("debug")("ticketman:TicketManager")
env = process.env.NODE_ENV || 'development'
DEFAULT_BASIC_AUTH = require('./config/config')[env]['basicAuth']

request = require "request"

PATH = "/api/tickets/new"

SQARSH_CALLBCAK = ()-> return


class TicketManager

  constructor: (@name, @host, basicAuth) ->
    assert @name, "missing name"
    assert @host, "missing host"

    @basicAuth = basicAuth || DEFAULT_BASIC_AUTH
    debuglog "[TicketManager.constructor] @name:#{@name}, @host:#{@host}, @basicAuth:%j", @basicAuth

  # issue a new ticket
  issue : (title, category, content, callback=SQARSH_CALLBCAK)->
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
      debuglog "err:#{err}, res.statusCode:#{if res? then res.statusCode else "n/a"}, body:%j", body
      return callback err if err?
      unless res.statusCode is 200
        return callback(new Error("Network error, res.statusCode:#{res.statusCode}"))
      unless body? and body.success and body.ticket
        return callback(new Error("Fail to create ticket:#{title}##{category}, due to #{body.error || "unknown error" + JSON.stringify(body)}"))

      body.ticket.id = body.ticket._id if body.ticket._id?
      return callback null, body.ticket


module.exports=TicketManager

