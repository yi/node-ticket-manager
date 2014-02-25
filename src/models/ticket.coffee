
## Module dependencies.

mongoose = require "mongoose"
Schema = mongoose.Schema
_ = require 'underscore'
timestamps = require "mongoose-times"

STATUS = require "../enums/ticket_status"

## Schema
TicketSchema = new Schema
  title : String
  owner_id : String
  status : {type: String, default: STATUS.PENDING }
  content : Schema.Types.Mixed
  comments : [{
    name : String
    type : String
    body : String
    date : Date
  }]

## Validations
TicketSchema.plugin timestamps,
  created: "created_at"
  lastUpdated: "updated_at"

TicketSchema.path('title').validate (title)->
  return title.length
, 'Title cannot be blank'

TicketSchema.path('content').validate (content)->
  return content?
, 'content cannot be blank'

TicketSchema.path('owner_id').validate (owner_id)->
  return owner_id.length
, 'Owner id cannot be blank'

## Pre-save hook
TicketSchema.pre 'save', (next)->
  #console.log "[ticket::pre save] isNew:#{@isNew}"
  return next() unless @isNew

  query =
    $and : [
      {title : @title}
      {status :
        $ne : [STATUS.COMPLETE, STATUS.ABANDON]
      }
    ]

  theTitle = @title
  mongoose.model('Ticket').findOne query, 'title', (err, ticket)->
    #console.log "[ticket::pre save] err:#{err}, ticket:%j", ticket
    return next(err) if err?
    return next(new Error("ticket #{theTitle} already exist")) if ticket?
    next()
    return
  return


## Instance Methods
TicketSchema.methods =

  complete : (callback)->
    this.status = STATUS.COMPLETE
    this.save(callback)
    return

  abandon : (callback)->
    this.status = STATUS.ABANDON
    this.save(callback)
    return

  appendLog : (name, type, body, callback)->
    return callback("missing log content") unless log?
    this.log.push
      name : name
      type : type
      body : body
      date : Date.now()
    this.save(callback)
    return


# mark a ticket as completed
# @param {Object} query, valid keys: id(:String), title(:String)
# @param {Callback} callback
TicketSchema.statics.changeStatus = (query, status, callback)->

  callback(new Error "invalid status:#{status}") unless STATUS.isValid status

  where = []
  if query.title? then where.push title:query.title
  else if query.id? then where.push id : query.id
  else callback(new Error("bad query, missing id neither title"))

  switch status
    when STATUS.COMPLETE
      # abandoned ticket must not be mark as completed
      where.push
        status :
          $ne : STATUS.ABANDON

    when STATUS.ABANDON
      # completed ticket must not be mark as abandoned
      where.push
        status :
          $ne : STATUS.COMPLETE

    when STATUS.PROCESSING
      # only pending ticket could be processing
      where.push
        status : STATUS.PENDING

  this.findOneAndUpdate ($and:where), {status: STATUS.COMPLETE}, callback
  return

mongoose.model('Ticket', TicketSchema)






