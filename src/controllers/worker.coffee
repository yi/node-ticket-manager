
mongoose = require('mongoose')
Worker = mongoose.model('Worker')

# list worker
# GET /workers
exports.index = (req, res, next)->

  Worker.find (err, workers)->
    return next err if err?
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

