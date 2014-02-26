
mongoose = require('mongoose')
Ticket = mongoose.model('Ticket')

# list tickets
exports.index = (req, res, next)->
  Ticket.find {}, (err, tickets)->
    return next err if err?
    res.render 'tickets/index',
      title: 'All Tickets'
      tickets : tickets
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


