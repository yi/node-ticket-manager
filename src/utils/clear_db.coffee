
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

_removeAbandoned = (callback) ->
  Ticket.removeByStatus STATUS.ABANDON, callback
  return


start = () ->
  setTimeout () ->
    _removeCompleted (err) ->
      console.error "clear_db::removeCompleted ERROR: #{err}" if err?
      start()
  , 7200000

start2 = () ->
  setTimeout () ->
    _removeAbandoned (err) ->
      console.error "clear_db::removeAbandoned ERROR: #{err}" if err?
      start2()
  , 28800000


start()

start2()

