
assert = require "assert"

debuglog = require("debug")("ticketman:TicketWorker")

oauth = require "./utils/oauth"

env = process.env.NODE_ENV || 'development'
DEFAULT_BASIC_AUTH = require('./config/config')[env]['basicAuth']

debuglog = require("debug")("ticketman:TicketWorker#")

{EventEmitter} = require('events')
request = require "request"

PATH_FOR_REQUIRE_TICKET = "/api/tickets/assign"

# job timeout setting
DEFAULT_TIMEOUT = 20*60*1000

# interval for watching
DEFAULT_WATCH_INTERVAL = 1000

# @event "new ticket", ticket
# @event "timeout", ticket
class TicketWorker extends EventEmitter

  # @param {Object} options, optionally includes:
  #     options.name
  #     options.id
  #     options.consumerSecret
  #     options.host
  #     options.watchCategory
  #     options.timeout : ticket processing timeout in ms
  #     options.interval : self checking interval
  #     options.basicAuth : basicAuth
  #
  constructor: (options={}) ->

    assert (@name = options.name), "missing id"
    assert (@id = options.id), "missing id"
    assert (@consumerSecret = options.consumer_secret), "missing consumer secret"
    assert (@watchCategory = options.category), "missing category to watch"
    assert (@host = options.host), "missing host"

    @oauth =
      consumer_key: @id
      consumer_secret: @consumerSecret

    @_isBusy = false
    @timeout = options.timeout || DEFAULT_TIMEOUT
    @interval = options.interval || DEFAULT_WATCH_INTERVAL
    @basicAuth = options.basicAuth || DEFAULT_BASIC_AUTH

    if @timeout < @interval * 3 then @timeout = @interval * 3

    @ticket = null
    @commenceAt = 0

    debuglog "constructor, @name:#{@name}, @watchCategory:#{@watchCategory}, @timeout:#{@timeout}, @interval:#{@interval}"
    setInterval (()=>@watch()), @interval

  isBusy : -> @_isBusy

  watch : ->
    debuglog "watch: isBusy:#{@isBusy()}"
    if @isBusy()
      @doTimeout() if Date.now() > @timeout +  @commenceAt
    else
      @requireTicket()
    return

  setBusy : (val)->
    @_isBusy = Boolean(val)
    @commenceAt = Date.now() if @_isBusy

  # require a new ticket from server
  requireTicket : ()->
    debuglog "requireTicket"
    return if @isBusy()

    @setBusy(true) # mark  i'm busy

    body = category : @watchCategory

    options =
      method: 'PUT'
      auth : @basicAuth
      url: "#{@host}#{PATH_FOR_REQUIRE_TICKET}"
      headers : oauth.makeSignatureHeader(@id, 'PUT', PATH_FOR_REQUIRE_TICKET, body, @consumerSecret)
      json : body

    request options, (err, res, result)=>
      debuglog "requireTicket: err:#{err}, res.statusCode:#{res.statusCode}, result:%j", result

      if err? then return debuglog "requireTicket: err: #{err}"

      unless res.statusCode is 200 then return debuglog "requireTicket: request failed, server status: #{res.statusCode}"

      unless result.success?
        @setBusy(false)
        debuglog "requireTicket: request failed, #{result.error}"
        return

      unless result.ticket?
        @setBusy(false)
        debuglog "requireTicket: no more ticket"
        return

      @ticket = result.ticket
      @ticket.id = @ticket._id if @ticket._id

      @emit "new ticket", @ticket
      return
    return

  # when timeout
  doTimeout : ->
    debuglog "doTimeout, @ticket:%j", @ticket
    @giveup()
    _ticket = @ticket
    @ticket = null
    @emit "timeout", _ticket
    @setBusy(false)
    return

  # complete ticket
  complete : ()->
    return unless @isBusy()

    path = "/api/tickets/#{@ticket.id}/complete"
    options =
      method: 'PUT'
      auth : @basicAuth
      headers : oauth.makeSignatureHeader(@id, 'PUT', path, {}, @consumerSecret)
      json : {}
      url: "#{@host}#{path}"

    request options, (err, res, ticket)->
      debuglog "complete: err:#{err}, res.statusCode:#{res.statusCode}, ticket:%j", ticket
      return

    _ticket = @ticket
    @ticket = null
    @emit "complete", _ticket
    @setBusy(false)
    return

  # send comment on to current ticket
  update : (message, kind='default')->
    return debuglog "update: ERROR: current has no ticket. message:#{message}" unless @ticket?

    body =
      kind : kind
      content : message

    path = "/api/tickets/#{@ticket._id}/comment"

    debuglog "=========== ticket:%j", @ticket

    options =
      method: 'PUT'
      auth : @basicAuth
      headers : oauth.makeSignatureHeader(@id, 'PUT', path, body, @consumerSecret)
      url: "#{@host}#{path}"
      json : body

    request options, (err, res, ticket)->
      debuglog "update: err:#{err}, res.statusCode:#{res.statusCode}, ticket:%j", ticket
      return
    return

  # give up the current ticket
  giveup: ()->
    debuglog "giveup"

    return unless @isBusy()

    path = "/api/tickets/#{@ticket.id}/giveup"

    options =
      method: 'PUT'
      auth : @basicAuth
      headers : oauth.makeSignatureHeader(@id, 'PUT', path, {}, @consumerSecret)
      url: "#{@host}#{path}"
      json : {}

    request options, (err, res, ticket)->
      debuglog "giveup: err:#{err}, res.statusCode:#{res.statusCode}, ticket:%j", ticket
      return

    @ticket = null
    @setBusy(false)
    return

module.exports=TicketWorker

