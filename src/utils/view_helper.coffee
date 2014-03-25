_ = require "underscore"

TICKET_STATUS_TO_INFO_TYPE =
  pending : 'default'
  processing : 'primary'
  completed : 'success'
  abandoned : 'danger'

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

  genLabelByStatus : (status)->
    return "<span class='label label-#{TICKET_STATUS_TO_INFO_TYPE[status] || 'default'}'>#{status}</span>"

  syntaxHighlight : (json) ->
    json = JSON.stringify(json, `undefined`, 2)  unless typeof json is "string"
    json = json.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
    json.replace /("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, (match) ->
      cls = "number"
      if /^"/.test(match)
        if /:$/.test(match)
          cls = "key"
        else
          cls = "string"
      else if /true|false/.test(match)
        cls = "boolean"
      else cls = "null"  if /null/.test(match)
      "<span class=\"" + cls + "\">" + match + "</span>"


module.exports = helpers
