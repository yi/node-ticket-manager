
class MongooseEndlessScroll

  DIRECTION_UP = "before"

  DIRECTION_DOWN = "after"

  DEFAULTS =
    itemsToKeep:       null
    inflowPixels:      50
    intervalFrequency: 250
    autoStart : true
    htmlLoading : "Loading..."
    htmlEnableScrollUp : "&uarr; More"
    htmlEnableScrollDown : "&darr; More"
    htmlDisableScrollUp : "~ No More ~"
    htmlDisableScrollDown : "~ No More ~"
    itemElementName : "a"
    paginationKey : "_id"

    formatItem : (item)->
      """
      <a href="/tickets/#{item._id}" class="list-group-item" id="#{item._id}">
        <div class="row"><div class="col-md-1">
          <span class="label label-success">#{item.status}</span>
        </div>
        <div class="col-md-2"><small><code>#{item._id}</code></small></div>
        <div class="col-md-5">#{item.title}</div>
        <div class="col-md-1">#{item.category}</div>
        <div class="col-md-1 text-right"><small title="2014-03-07T09:11:34.813Z" class="muted timeago">#{item.created_at}</small></div>
        <div class="col-md-1 text-right"><small title="2014-03-07T09:11:52.074Z" class="muted timeago">#{item.updated_at}</small></div>
        <div class="col-md-1">#{item.attempts}</div></div></a>
      """


  constructor: (scope, options) ->
    @options = $.extend({}, DEFAULTS , options)
    @container = $(options.container)

    @elControlUp = @options.elControlUp
    @elControlUp.click => @fetchUp()
    @elControlDown = @options.elControlDown
    @elControlDown.click => @fetchDown()

    @topmostId = null
    @bottonmostId = null

    @query = {}

    #kv hash, key: record id, value: record data
    @idToData = {}

    # ordered record id
    @ids = []

    @showLoading false

    #scrollListener = =>
      #$(window).one "scroll", =>
        #if ($(window).scrollTop() >= $(document).height() - $(window).height() - @options.inflowPixels)
          #@fetchDown()
        #else if $(window).scrollTop() <= @options.inflowPixels
          #@fetchUp()
        #setTimeout scrollListener, @options.intervalFrequency

    $(document).ready =>
      #scrollListener()
      if @options.autoStart then @fetchDown()

    return

  toString : ->
    "[MongooseEndlessScroll]"

  empty : ->
    @container.empty()
    @topmostId = null
    @bottonmostId = null
    @idToData = {}
    @ids = []
    @showLoading false
    return


  fetchDown : ->
    #console.log "[jquery.mongoose-endless-scroll::fetchDown] @options.inflowPixels:#{@options.inflowPixels}"
    #$(window).scrollTop($(document).height() - $(window).height() - @options.inflowPixels)

    data = $.extend {}, @query
    id = @ids[@ids.length - 1]
    record = @idToData[id]
    data[DIRECTION_DOWN] = record[@options.paginationKey] if record?
    @fetch data
    return

  fetchUp: ->
    #console.log "[jquery.mongoose-endless-scroll::fetchUp] "
    #$(window).scrollTop(@options.inflowPixels)

    data = $.extend {}, @query
    id =  @ids[0]
    record = @idToData[id]
    data[DIRECTION_UP] = record[@options.paginationKey] if record?
    @fetch data
    return

  showLoading : (val)->
    #console.log "[jquery.mongoose-endless-scroll::showLoading]@topmostId:#{@topmostId}, @bottonmostId:#{@bottonmostId}]"

    @isFecthing = Boolean(val)
    if @isFecthing
      @elControlDown.html(@options.htmlLoading)
      @elControlUp.html(@options.htmlLoading)
    else
      if @topmostId
        @elControlUp.html(@options.htmlDisableScrollUp)
        #console.log "[jquery.mongoose-endless-scroll::method]@elControlUp.is(:visible) #{@elControlUp.is(":visible")}"

        @elControlUp.fadeOut() if @elControlUp.is(":visible")
      else
        @elControlUp.html(@options.htmlEnableScrollUp)
        @elControlUp.fadeIn() unless @elControlUp.is(":visible")

      if @bottonmostId
        @elControlDown.html(@options.htmlDisableScrollDown)
        @elControlDown.fadeOut() if @elControlDown.is(":visible")
      else
        @elControlDown.html(@options.htmlEnableScrollDown)
        @elControlDown.fadeIn() unless @elControlDown.is(":visible")

      #@elControlUp.html(if @topmostId then @options.htmlDisableScrollUp else @options.htmlEnableScrollUp)
      #@elControlDown.html(if @bottonmostId then @options.htmlDisableScrollDown else @options.htmlEnableScrollDown)


  fetch : (data)->
    #console.log "[jquery.mongoose-endless-scroll::fetch] "
    #console.dir data

    if @isFecthing
      console.log "[jquery.mongoose-endless-scroll::fetch] in fetching"
      return

    if (data[DIRECTION_DOWN] is @bottonmostId) || (data[DIRECTION_UP] is @topmostId)
      console.log "[jquery.mongoose-endless-scroll::fetch] reach boundary"
      return

    # lock on
    @showLoading true
    #@isFecthing = true

    ajaxOptions =
      dataType : "json"
      url : @options.serviceUrl
      data : data
      success : (res, textStatus)=>
        # release lock
        @showLoading false
        #@isFecthing = false

        # figure out direction
        currentDirection = if data[DIRECTION_UP]? then DIRECTION_UP else DIRECTION_DOWN

        res.results or= []
        pos = 0
        while pos < res.results.length
          item = res.results[pos]
          if ~@ids.indexOf(item._id)
            console.log "[jquery.mongoose-endless-scroll::remove duplicate] id:#{item._id} title:#{item.title}"
            res.results.splice pos, 1
          else
            ++pos

        # validate result
        unless Array.isArray(res.results) and res.results.length
          # reach boundary
          if currentDirection is DIRECTION_DOWN
            @bottonmostId = data[DIRECTION_DOWN]
          else
            @topmostId = data[DIRECTION_UP]
          console.log "[jquery.mongoose-endless-scroll::reach boundary] @topmostId:#{@topmostId}, @bottonmostId:#{@bottonmostId}"
          @showLoading false
          return

        @addInResults(res.results, currentDirection)

        # render partial
        if currentDirection is DIRECTION_DOWN then @renderBottomPartial() else @renderTopPartial()

        # clear redundancy
        if @options.itemsToKeep > 0 and (diff = @ids.length - @options.itemsToKeep) > 0
          @clearRedundancy(diff, currentDirection)

        # fire callback
        @options["onChange"]() if(typeof(@options["onChange"]) is "function")

        return

      error : (jqXHR, textStatus, err)=>
        console.log "[jquery.mongoose-endless-scroll::error] err:#{err}"
        @container.trigger("mescroll_error", err)
        @showLoading false
        return

    $.ajax ajaxOptions
    return

  clearRedundancy : (count, direction)->
    #console.log "[jquery.mongoose-endless-scroll::clearRedundancy] count:#{count}, direction:#{direction}"

    #debugger
    while(count > 0)
      # remove on the opposite side
      id = if direction is DIRECTION_DOWN then @ids.shift() else @ids.pop()

      item = @idToData[id]
      #console.log "[jquery.mongoose-endless-scroll::clearRedundancy] item:#{item.title}"

      delete @idToData[id]
      $("##{id}").remove()
      --count

    # show the more handler
    if direction is DIRECTION_DOWN
      #@elControlUp.show()
      @topmostId = null
      @showLoading(false)
    else
      #@elControlDown.show()
      @bottonmostId = null
      @showLoading(false)

    #console.log "[jquery.mongoose-endless-scroll::clearRedundancy] after clear, ids:\n#{@ids.map((id)=>@idToData[id].title).join("\n")}"
    return

  addInResults : (results, direction)->
    #results.reverse() if direction is DIRECTION_UP
    for result in results
      id = result._id
      continue if ~@ids.indexOf(id)
      if direction is DIRECTION_DOWN
        #console.log "[jquery.mongoose-endless-scroll::addInResults] push: #{result.title}"
        @ids.push id
      else
        #console.log "[jquery.mongoose-endless-scroll::addInResults] unshift: #{result.title}"
        @ids.unshift id
      @idToData[id] = result
    return

  getDisplayedTopmostId : -> $("#{@container.selector} #{@options.itemElementName}").first().attr("id")

  getDisplayedBottommostId : -> $("#{@container.selector} #{@options.itemElementName}").last().attr("id")

  renderTopPartial : ()->
    topmostId = @getDisplayedTopmostId()
    pos = @ids.indexOf(topmostId) - 1
    if pos < -1 then pos = @ids.length - 1
    while(pos > -1)
      id = @ids[pos]
      item = @idToData[id]
      #console.log "[jquery.mongoose-endless-scroll::renderTopPartial] item:#{item.title}"
      @container.prepend(@options.formatItem(item))
      -- pos
    return

  renderBottomPartial : ()->
    bottonmostId = @getDisplayedBottommostId()
    pos = @ids.indexOf(bottonmostId)
    if pos <= -1
      pos = 0
    else
      pos += 1 # render from (not include) current displayer bottom most one
    while(pos < @ids.length)
      id = @ids[pos]
      item = @idToData[id]
      #console.log "[jquery.mongoose-endless-scroll::renderBottomPartial] item:#{item.title}"
      @container.append(@options.formatItem(item))
      ++pos

    return

(($) ->
  $.fn.mongooseEndlessScroll = (options) ->
    new MongooseEndlessScroll(this, options)
)(jQuery)

