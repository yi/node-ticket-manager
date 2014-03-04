
mongoose = require('mongoose')
Ticket = mongoose.model('Ticket')
STATUS = require "../enums/ticket_status"

debuglog = require("debug")("ticketman:controller:ticket")

# list tickets
# GET /
# GET /tickets
exports.index = (req, res, next)->
  debuglog "index"
  Ticket.find().sort({created_at:'desc'}).exec (err, tickets)->
    return next err if err?
    res.render 'tickets/index',
      title: 'All Tickets'
      tickets : tickets
    return
  return

# GET /tickets/:id
exports.show = (req, res, next)->
  debuglog "show"
  id = String(req.params.id || '')
  return next() unless id?
  Ticket.findById id, (err, ticket)->
    return next err if err?
    res.render 'tickets/show',
      title: 'All Tickets'
      ticket : ticket
    return
  return


# POST /api/tickets/new
exports.create = (req, res, next)->
  debuglog "create"
  ticket = new Ticket(req.body)
  ticket.save (err)=>
    if err?
      return res.json
        success : false
        error : err.toString()
    else
      return res.json
        success : true
        ticket : ticket
  return

# PUT /api/tickets/assign
exports.assign = (req, res, next)->
  debuglog "assign, req.worker:%j", req.worker
  req.body.worker = req.worker.name
  Ticket.arrangeAssignment req.body, (err, ticket) ->
    return next(err) if err?

    unless ticket?
      return res.json
        success : false
        error : "no pending ticket of #{req.body.category}"

    return res.json
      success : true
      ticket : ticket
  return

# PUT /api/tickets/:id/comment
exports.comment = (req, res, next)->
  id = req.params.id || ''
  return next() unless id?

  req.body.name = req.worker.name

  Ticket.addComment id, req.body, (err, ticket)->
    return next(err) if err?

    unless ticket?
      return res.json
        success : false
        error : "no commented ticket of #{id}"

    return res.json
      success : true
      ticket : ticket

  return

# PUT /api/tickets/:id/complete
exports.complete = (req, res, next)->
  id = String(req.params.id || '')
  return next() unless id?

  req.body.id = id

  Ticket.changeStatus req.body, STATUS.COMPLETE, (err, ticket)->
    return next(err) if err?
    return next() unless ticket?
    return res.json ticket
  return


# PUT /api/tickets/:id/giveup
exports.giveup = (req, res, next)->

  id = String(req.params.id || '')
  return next() unless id?

  req.body.id = id

  comment =
    name: req.worker.name
    kind: "danger"
    content : req.body.reason || "#{req.worker.name} fail to process this ticket"

  Ticket.addComment id, comment, (err, ticket)->
    return next(err) if err?

    unless ticket?
      return res.json
        success : false
        error : "missing ticket of #{id}"

    Ticket.changeStatus req.body, STATUS.PENDING, (err, ticket)->
      return next(err) if err?
      return next() unless ticket?

      ticket.update {$inc: {attempts:1}}, (err, numberAffected)->
        return next(err) if err?
        ticket.attempts = numberAffected
        return res.json ticket

      return
    return
  return


# PUT  /tickets/:id/abandon
exports.abandon = (req, res, next)->
  id = String(req.params.id || '')
  return next() unless id?

  Ticket.findById id, (err, ticket)->
    return next err if err?
    return next() unless ticket?
    return next(new Error "only pending ticket could be abandoned") unless ticket.status is STATUS.PENDING

    Ticket.changeStatus {id : ticket.id}, STATUS.ABANDON, (err, ticket)->
      return next err if err?
      return next() unless ticket?
      return res.redirect "/tickets"
    return
  return

# PUT  /tickets/:id/comment
exports.adminComment = (req, res, next)->
  id = String(req.params.id || '')
  return next() unless id?

  req.body.content = req.body.content.trim()
  console.log "[ticket::==========] req.body.content:#{req.body.content}"

  return next(new Error "please say something") unless req.body.content

  req.body.kind = "warning"
  req.body.name = "admin"

  Ticket.addComment id, req.body, (err, ticket)->
    return next(err) if err?

    return next() unless ticket?

    return res.redirect "/tickets/#{id}"

  return


