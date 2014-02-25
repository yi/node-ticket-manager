
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

TicketSchema.plugin timestamps,
  created: "created_at"
  lastUpdated: "updated_at"

UserSchema.path('title').validate (title)->
  return title.length
, 'Title cannot be blank'

UserSchema.path('owner_id').validate (owner_id)->
  return owner_id.length
, 'Owner id cannot be blank'


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






