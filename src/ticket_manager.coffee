
mongoose = require('mongoose')
require "./ticket"
Ticket = mongoose.model('Ticket')

class TicketManager

  constructor: ()->

    issue : (title, owner, content, callback)->
      (new Ticket(
        title : title
        owner_id : owner
        content : content))
      .save callback




module.exports=TicketManager


