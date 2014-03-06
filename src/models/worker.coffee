
## Module dependencies.

mongoose = require "mongoose"
Schema = mongoose.Schema
_ = require 'underscore'
timestamps = require "mongoose-times"
paginator = require 'mongoose-paginator'


## Schema
schemaStructure =
  name: String
  desc: String
  count_success : {type:Number, default:0}
  count_failure : {type:Number, default:0}
  consumer_secret : String

genUUID = (a)->
  return if a then (0|Math.random()*16).toString(16) else (""+1e7+-1e3+-4e3+-8e3+-1e11).replace(/1|0/g,genUUID)

MAX_LENGTH_OF_NAME = 50

MAX_LENGTH_OF_DESC = 200

WorkerSchema = new Schema(schemaStructure)

## Plugins
WorkerSchema.plugin timestamps,
  created: "created_at"
  lastUpdated: "updated_at"

## Validations
WorkerSchema.path('name').validate (val)->
  return val.length
, 'Name cannot be blank'

## Validations
WorkerSchema.path('desc').validate (val)->
  return val.length
, 'Desc cannot be blank'

WorkerSchema.plugin paginator,
  limit: 10
  defaultKey: '_id'
  direction: -1

## Pre-save hook
WorkerSchema.pre 'save', (next)->
  #console.log "[ticket::pre save] isNew:#{@isNew}"
  return next() unless @isNew

  @name = @name.trim().replace(/\s/g, '').toLowerCase().substr(0,MAX_LENGTH_OF_NAME)
  @desc = @desc.trim().substr(0, MAX_LENGTH_OF_DESC)

  mongoose.model('Worker').findOne {name : @name}, (err, worker)=>
    #console.log "[ticket::pre save] err:#{err}, ticket:%j", ticket
    return next(err) if err?
    return next(new Error("worker #{@name} already exist")) if worker?
    @consumer_secret = genUUID()

    next()
    return
  return


mongoose.model('Worker', WorkerSchema)

