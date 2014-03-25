
## Module dependencies.

mongoose = require "mongoose"
Schema = mongoose.Schema
_ = require 'underscore'
timestamps = require "mongoose-times"
paginator = require 'mongoose-paginator'

STATUS = require "../enums/ticket_status"

EMPTY_OBJ = {}

MIN_FIELD_SELECTION =
  select : 'id'

## Schema
schemaStructure =
  title : String
  owner_id : String
  attempts : {type:Number, default: 0}
  category : String
  status : {type: String, default: STATUS.PENDING }
  content : Schema.Types.Mixed
  #comments : [Schema.Types.Mixed]
  comments : [{
    name : String
    kind : String
    content : String
    date : Date
  }]

schemaOptions = {}
  #capped : 32768

TicketSchema = new Schema(schemaStructure, schemaOptions)

## Plugins
TicketSchema.plugin timestamps,
  created: "created_at"
  lastUpdated: "updated_at"

TicketSchema.plugin paginator,
  limit: 10,
  defaultKey: '_id',
  direction: 'desc'

## Validations
TicketSchema.path('title').validate (val)->
  return val.length
, 'Title cannot be blank'

TicketSchema.path('category').validate (val)->
  return val.length
, 'Category cannot be blank'

TicketSchema.path('content').validate (val)->
  return val?
, 'content cannot be blank'

TicketSchema.path('owner_id').validate (val)->
  return val.length
, 'Owner id cannot be blank'

## Pre-save hook
TicketSchema.pre 'save', (next)->
  #console.log "[ticket::pre save] isNew:#{@isNew}"
  return next() unless @isNew

  query =
    $and : [
      {title : @title}
      {status :
        $not : new RegExp("(#{STATUS.COMPLETE}|#{STATUS.ABANDON})")
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
# @param {Callback} callback, signature: callback(err, ticket)
TicketSchema.statics.changeStatus = (query, status, callback)->
  console.log "[ticket::changeStatus] "

  return callback(new Error "invalid status:#{status}") unless STATUS.isValid status

  where = []
  if query.title? then where.push {title:query.title}
  else if query.id? then where.push {_id : query.id}
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

  this.findOneAndUpdate ($and:where), {status: status, updated_at : Date.now()}, (err, ticket)=>
    console.log "[ticket] err:#{err}, ticket:%j", ticket
    return callback err if err?
    return callback(new Error "missing ticket for query: #{JSON.stringify(query)}") unless ticket?
    comment =
      name : query.worker || query.whoami || query.name || "system"
      kind : "primary"
      content:"change ticket status to #{status}"

    this.addComment ticket.id, comment , callback
    return

  return

# add comment to a ticket
# @param {String} id
# @param {Object} comment, must have keys: name, kind, content
# @param {Function} callback, signature: callback(err, ticket)
TicketSchema.statics.addComment = (id, comment, callback)->

  unless id? and comment.name? and comment.kind? and comment.content? and callback?
    return callback(new Error("missing arrgument. id:#{id}, name:#{comment.name}, kind:#{comment.kind}, content:#{comment.content}, callback:#{callback}"))

  console.log "[ticket::addComment] id:%j", id

  comment.date = Date.now()

  update =
    $push :
      comments : comment
    $set :
      updated_at : Date.now()

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

# find the eldest pending task and assign it to worker
# @param {Object} options , must have keys: worker, category
# @param {Function} callback, signature: callback(err, ticket)
TicketSchema.statics.arrangeAssignment = (options, callback)->

  options or= EMPTY_OBJ
  worker = String(options.worker || options.name || "")
  category = String(options.category || "")

  return callback(new Error("missing request params, worker:#{worker}, category:#{category}")) unless worker and category

  query =
    $and :[
      {category : category}
      {status : STATUS.PENDING}
    ]

  this.findOne(query).sort({updated_at : 'asc'}).exec (err, ticket)=>
    return callback err if err?
    return callback() unless ticket? # no avaliable ticket

    options.id = ticket.id
    this.changeStatus options, STATUS.PROCESSING, callback
    return
  return


mongoose.model('Ticket', TicketSchema)






