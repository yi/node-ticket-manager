
mongoose = require('mongoose')
Ticket = mongoose.model('Ticket')
STATUS = require "../enums/ticket_status"

# list tickets
# GET /
# GET /tickets
exports.index = (req, res, next)->
  Ticket.find().sort({created_at:'desc'}).exec (err, tickets)->
    return next err if err?
    res.render 'tickets/index',
      title: 'All Tickets'
      tickets : tickets
    return
  return

# GET /tickets/:id
exports.show = (req, res, next)->
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
  req.body.worker = req.worker.name
  Ticket.arrangeAssignment req.body, (err, ticket) ->
    return next(err) if err?
    return next() unless ticket?
    return res.json ticket
  return

# PUT /api/tickets/:id/comment
exports.comment = (req, res, next)->
  id = req.params.id || ''
  return next() unless id?

  console.log "[ticket::comment] id:#{id}"
  console.dir req.params

  Ticket.addComment id, req.body, (err, ticket)->
    return next(err) if err?
    return next() unless ticket?
    return res.json ticket
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

  Ticket.changeStatus req.body, STATUS.PENDING, (err, ticket)->
    return next(err) if err?
    return next() unless ticket?

    ticket.update {$inc: {attempts:1}}, (err, numberAffected)->
      return next(err) if err?
      ticket.attempts = numberAffected
      return res.json ticket

    return
  return




