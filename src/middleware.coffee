oauth = require "./utils/oauth"

EMPTY_ARRAY = []

mongoose = require('mongoose')
Worker = mongoose.model('Worker')

exports.authWorker = (req, res, next)->

  signature = req.headers['ticketman-authenticate']
  return next(new Error "signature checking failed") unless signature? and signature.indexOf("Ticketman") is 0

  workerId = (signature.match(/Ticketman ([^:]+)/) || EMPTY_ARRAY)[1]
  signature = (signature.match(/:([^:]+)/) || EMPTY_ARRAY)[1]

  return next(new Error("invalid signature")) unless workerId? and signature?

  Worker.findById workerId, (err, worker)->
    return next err if err?
    return next(new Error "missing worker #{workerId}") unless worker
    if oauth.verify(signature, req.method, req.url, req.body, worker['consumer_secret']) and not worker.trashed_at?
      req.worker = worker
      next()
    else
      next(new Error "signature mismatch")
    return
  return

exports.updateWorkerAt = (req, res, next) ->
  signature = req.headers['ticketman-authenticate']
  workerId = (signature.match(/Ticketman ([^:]+)/) || EMPTY_ARRAY)[1]

  Worker.findByIdAndUpdate workerId, {updated_at: Date.now()}, (err, worker) ->
    return next err if err?
    next()
