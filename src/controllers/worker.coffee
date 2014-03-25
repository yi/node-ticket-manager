
mongoose = require('mongoose')
Worker = mongoose.model('Worker')

# list tickets
# GET /workers
exports.index = (req, res, next)->
  Worker.find().sort({created_at:'desc'}).exec (err, workers)->
    return next err if err?
    res.render 'workers/index',
      title: 'All Workers'
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
