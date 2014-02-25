
## Module dependencies.

mongoose = require "mongoose"
Schema = mongoose.Schema
_ = require 'underscore'
timestamps = require "mongoose-times"
paginator = require 'mongoose-paginator'

STATUS = require "./ticket_status"

MIN_FIELD_SELECTION =
  select : 'id'

## Schema
TicketSchema = new Schema
  title : String
  owner_id : String
  status : {type: String, default: STATUS.PENDING }
  content : Schema.Types.Mixed
  #comments : [Schema.Types.Mixed]
  comments : [{
    name : String
    kind : String
    content : String
    date : Date
  }]

## Plugins
TicketSchema.plugin timestamps,
  created: "created_at"
  lastUpdated: "updated_at"

TicketSchema.plugin paginator,
  limit: 50,
  defaultKey: '_id',
  direction: 1

## Validations
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
#TicketSchema.methods =


# mark a ticket as completed
# @param {Object} query, valid keys: id(:String), title(:String)
# @param {Callback} callback
TicketSchema.statics.changeStatus = (query, status, callback)->
  console.log "[ticket::changeStatus] "

  return callback(new Error "invalid status:#{status}") unless STATUS.isValid status

  where = []
  if query.title? then where.push title:query.title
  else if query.id? then where.push id : query.id
  else return callback(new Error("bad query, missing id neither title"))

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

  this.findOneAndUpdate ($and:where), {status: status}, MIN_FIELD_SELECTION, (err, ticket)=>
    console.log "[ticket] err:#{err}, ticket:%j", ticket
    return callback err if err?
    return callback(new Error "missing ticket for query: #{JSON.stringify(query)}") unless ticket?
    this.addComment ticket.id, "system", "primary", "change ticket status to #{status}", callback
    return

  return

TicketSchema.statics.addComment = (id, name, kind, content, callback)->
  console.log "[ticket::addComment]"

  unless id? and name? and kind? and content? and callback?
    return callback(new Error("missing arrgument. id:#{id}, name:#{name}, kind:#{kind}, content:#{content}, callback:#{callback}"))

  update =
    $push :
      comments :
        name : name
        kind : kind
        content : content
        date : Date.now()

  this.findByIdAndUpdate id, update, callback
  return

# !not working yet!
TicketSchema.statics.list = (status, after, callback)->
  where = []
  if STATUS.isValid status then where.push status : status
  if after? then where.push after:after
  where = {
    $and : where
  }
  this.paginate(where, '_id').execPagination callback

mongoose.model('Ticket', TicketSchema)






