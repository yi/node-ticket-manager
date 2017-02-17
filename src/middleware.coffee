oauth = require "./utils/oauth"

EMPTY_ARRAY = []

mongoose = require('mongoose')
Worker = mongoose.model('Worker')

exports.authWorker = (req, res, next)->

  signature = req.headers['ticketman-authenticate']
  return next(new Error "signature checking failed") unless signature? and signature.indexOf("Ticketman") is 0

  workerId = (signature.match(/Ticketman ([^:]+)/) || EMPTY_ARRAY)[1]
  signature = (signature.match(/:([^:]+)/) || EMPTY_ARRAY)[1]

  return next(new Error("invalid signature workerId:#{workerId} signature:#{signature}")) unless workerId? and signature?

  Worker.findById workerId, (err, worker)->
    return next err if err?
    return next(new Error "missing worker #{workerId}") unless worker
    #console.log "a: " + (worker.trashed_at == null)
    #console.log "b: " + (typeof(worker.trashed_at) == "undefined")
    #console.log "c: " + (worker.trashed_at == "undefined")
    unless typeof(worker.trashed_at) == "undefined"
      return next(new Error "worker is trashed  #{workerId}")
    if oauth.verify(signature, req.method, req.url, req.body, worker['consumer_secret'])
      req.worker = worker
      next()
    else
      next(new Error "signature mismatch #{workerId} signature:#{signature}")
    return
  return

exports.updateWorkerAt = (req, res, next) ->
  signature = req.headers['ticketman-authenticate']
  workerId = (signature.match(/Ticketman ([^:]+)/) || EMPTY_ARRAY)[1]

  Worker.findByIdAndUpdate workerId, {updated_at: Date.now()}, (err, worker) ->
    return next err if err?
    next()
