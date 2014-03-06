
mongoose = require('mongoose')
Worker = mongoose.model('Worker')

# list worker
# GET /workers
exports.index = (req, res, next)->

  Worker.paginate(req, '_id').execPagination (err, result)->
    return next err if err?
    return next() unless result? and Array.isArray(result.results) and result.results.length
    console.dir result

    res.render 'workers/index', result
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

