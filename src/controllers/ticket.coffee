
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
