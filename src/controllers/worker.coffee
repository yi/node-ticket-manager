
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

