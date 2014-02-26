
# list tickets
exports.index = (req, res, next)->
  res.render 'tickets/index',
    title: 'All Tickets'
  return
