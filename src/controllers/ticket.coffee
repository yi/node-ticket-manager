
# list tickets
exports.list = (req, res, next)->
  res.render 'home/index',
    title: 'Demo'
  return
