
mongoose = require('mongoose')
Worker = mongoose.model('Worker')

# list tickets
# GET /workers
exports.index = (req, res, next)->


  Worker.paginate(req, '_id').execPagination (err, result)->
    return next err if err?
    return next() unless result?
    console.dir result

    res.render 'workers/index', result
    return
  return

  #Worker.find().sort({created_at:'desc'}).exec (err, workers)->
    #return next err if err?
    #res.render 'workers/index',
      #title: 'All Workers'
      #workers : workers
    #return
  #return

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

