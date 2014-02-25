
# Module dependencies.

mongoose = require "mongoose"
Schema = mongoose.Schema
_ = require 'underscore'
timestamps = require "mongoose-times"

STATUS = require "../enums/ticket_status"

# Schema
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

# Validations
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

# Pre-save hook
TicketSchema.pre 'save', (next)->
  return next() if (!@isNew)

  query =
    $and :
      title : @title
      $or :
        status :
          $ne : STATUS.COMPLETE
          $ne : STATUS.ABANDON

  TicketSchema.findOne query, (err, ticket)->
    return next err if err?
    return "ticket already exist" if ticket?
    next()
    return
  return


# Methods
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

mongoose.model('Ticket', TicketSchema)






