
mongoose = require('mongoose')
Ticket = mongoose.model('Ticket')
STATUS = require "../enums/ticket_status"


_removeCompleted = (callback) ->
  Ticket.removeByStatus STATUS.COMPLETE, callback
  return

  #Ticket.count {status:STATUS.COMPLETE}, (err, count) ->
  #  return callback err if err?
  #  console.log "Ticket:completed count:#{count}"
  #  if count<500
  #    return callback()
  #  Ticket.removeByStatus STATUS.COMPLETE, callback
  #  return
  #return

start = () ->
  setTimeout () ->
    _removeCompleted (err) ->
      console.error "clear_db::removeCompleted ERROR: #{err}" if err?
      start()
  , 7200000

start()
