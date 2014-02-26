
mongoose = require('mongoose')
Ticket = mongoose.model('Ticket')

# list tickets
# GET /
# GET /tickets
exports.index = (req, res, next)->
  Ticket.find {}, (err, tickets)->
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

#
exports.assign = (req, res, next)->
  return

#
exports.comment = (req, res, next)->
  return

#
exports.complete = (req, res, next)->
  return

#
exports.giveup = (req, res, next)->
  return

#
exports.create = (req, res, next)->
  return


