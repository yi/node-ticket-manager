
mongoose = require('mongoose')
Worker = mongoose.model('Worker')

# list worker
# GET /workers
exports.index = (req, res, next)->

  Worker.find (err, workers)->
    return next err if err?
    #console.dir  workers
    res.render 'workers/index',
      workers : workers
    return
  return

# POST /workers/new
exports.create = (req, res, next)->
  ticket = new Worker(req.body)
  ticket.save (err)=>
    return next err if err?

    switch req.params.format
      when 'json' then res.json ticket
      else res.redirect "/workers"

    return
  return

exports.updateAt = (req, res, next) ->
  signature = req.headers['ticketman-authenticate']
  return next(new Error "signature checking failed") unless signature? and signature.indexOf("Ticketman") is 0

  workerId = (signature.match(/Ticketman ([^:]+)/) || EMPTY_ARRAY)[1]
  update =
    updated_at: Date.now()
  Worker.findByIdAndUpdate workerId,update, (err,worker) ->
    return next err if err?
    next()

exports.trashed = (req, res, next) ->
  workerId = req.body.worker_id
  Worker.findById workerId, (err, worker) ->
    return next err if err?
    return next 404 unless worker

    worker[if worker.trashed_at? then "untrash" else "trash"] (err) ->
      return next err if err?
      res.redirect "/workers"
