_ = require "underscore"

helpers =

  # 产生 json 文件下载地址
  generateDownloadPathByJson : (jsonId) ->
    return "/assets/json/#{jsonId}.json"

  # 产生 json id 文件下载的HTML代码
  genDownloadTagByJsonId : (jsonId, title) ->
    url = helpers.generateDownloadPathByJson jsonId
    return "<a href='#{url}' class='btn btn-link'><i class='glyphicon glyphicon-download-alt'> </i> #{title || jsonId}</a>"

  genDateTag : (date) ->
    isoStr = if date instanceof Date then date.toISOString() else date
    dateStr = if date instanceof Date then date.toDateString() else date
    return "<small title='#{isoStr}' class='muted timeago'>#{dateStr}</small>"

  genPagination : (pageData)->
    return pagination.create('search', pageData).render()

module.exports = helpers
