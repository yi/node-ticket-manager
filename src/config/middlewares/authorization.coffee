
# Generic require login routing middleware
exports.requiresLogin = (req, res, next)->
  return res.redirect('/login') unless req.isAuthenticated()
  next()


#  User authorizations routing middleware
exports.user =
  hasAuthorization : (req, res, next)->
    return res.redirect('/users/'+req.profile.id) if req.profile.id isnt req.user.id
    next()


#  Article authorizations routing middleware
exports.article =
  hasAuthorization : (req, res, next)->
    return res.redirect('/articles/'+req.article.id) if req.article.user.id isnt req.user.id
    next()
