
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
    @elControlUp.click => @fetchPrev()
    @elControlDown = @options.elControlDown
    @elControlDown.click => @fetchNext()

    @topmostId = null
    @downmonstId = null

    #kv hash, key: record id, value: record data
    @idToData = {}

    # ordered record id
    @ids = []

    @showLoading false
    #@isFecthing = false
    console.log "[jquery.mongoose-endless-scroll::options]"
    console.dir options

    #scrollListener = =>
      #$(window).one "scroll", =>
        #if ($(window).scrollTop() >= $(document).height() - $(window).height() - @options.inflowPixels)
          #@fetchNext()
        #else if $(window).scrollTop() <= @options.inflowPixels
          #@fetchPrev()
        #setTimeout scrollListener, @options.intervalFrequency

    $(document).ready =>
      #scrollListener()
      if @options.autoStart then @fetchNext()

    return

  fetchNext : ->
    #console.log "[jquery.mongoose-endless-scroll::fetchNext] @options.inflowPixels:#{@options.inflowPixels}"
    #$(window).scrollTop($(document).height() - $(window).height() - @options.inflowPixels)

    data = {}
    data[DIRECTION_DOWN] = @ids[@ids.length - 1]
    @fetch data
    return

  fetchPrev: ->
    #console.log "[jquery.mongoose-endless-scroll::fetchPrev] "
    #$(window).scrollTop(@options.inflowPixels)

    data = {}
    data[DIRECTION_UP] = @ids[0]
    @fetch data
    return

  showLoading : (val)->
    console.log "[jquery.mongoose-endless-scroll::@topmostId:#{@topmostId}, @bottomostId:#{@bottomostId}]"

    @isFecthing = Boolean(val)
    if @isFecthing
      @elControlDown.html(@options.htmlLoading)
      @elControlUp.html(@options.htmlLoading)
    else
      @elControlUp.html(if @topmostId then @options.htmlDisableScrollUp else @options.htmlEnableScrollUp)
      @elControlDown.html(if @bottomostId then @options.htmlDisableScrollDown else @options.htmlEnableScrollDown)


  fetch : (data)->
    #console.log "[jquery.mongoose-endless-scroll::fetch] "
    #console.dir data

    if @isFecthing
      console.log "[jquery.mongoose-endless-scroll::fetch] in fetching"
      return

    #debugger

    if (data[DIRECTION_DOWN] is @downmonstId) || (data[DIRECTION_UP] is @topmostId)
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
        #console.log "[jquery.mongoose-endless-scroll::receive] textStatus:#{textStatus}, res:"
        #console.dir res
        #console.dir data

        # release lock
        @showLoading false
        #@isFecthing = false

        # figure out direction
        currentDirection = if data[DIRECTION_DOWN]? then DIRECTION_DOWN else DIRECTION_UP
        #console.log "[jquery.mongoose-endless-scroll::receive] currentDirection:#{currentDirection}"

        #debugger

        res.results or= []
        pos = 0
        while pos < res.results.length
          item = res.results[pos]
          if ~@ids.indexOf(item._id)
            console.log "[jquery.mongoose-endless-scroll::remove duplicate] id:#{item._id}"
            res.results.splice pos, 1
          else
            ++pos

        # validate result
        unless Array.isArray(res.results) and res.results.length
          # reach boundary
          if currentDirection is DIRECTION_DOWN
            @downmonstId = data[DIRECTION_DOWN]
            @elControlDown.html @options.htmlDisableScrollDown
            #@elControlDown.hide()
          else
            @topmostId = data[DIRECTION_UP]
            @elControlUp.html @options.htmlDisableScrollUp
            #@elControlUp.hide()
          console.log "[jquery.mongoose-endless-scroll::reach boundary] @topmostId:#{@topmostId}, @downmonstId:#{@downmonstId}"

          return

        @addInResults(res.results, currentDirection)

        # render partial
        if currentDirection is DIRECTION_DOWN then @renderBottomPartial() else @renderTopPartial()

        # clear redundancy
        if @options.itemsToKeep > 0 and (diff = @ids.length - @options.itemsToKeep) > 0
          @clearRedundancy(diff, currentDirection)

        return

      error : (jqXHR, textStatus, err)=>
        console.log "[jquery.mongoose-endless-scroll::error] err:#{err}"
        @container.trigger("mescroll_error", err)
        @showLoading false
        #@isFecthing = false
        return

    $.ajax ajaxOptions
    return

  clearRedundancy : (count, direction)->
    console.log "[jquery.mongoose-endless-scroll::clearRedundancy] count:#{count}, direction:#{direction}"

    #debugger
    while(count > 0)
      # remove on the opposite side
      id = if direction is DIRECTION_DOWN then @ids.shift() else @ids.pop()

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
      @bottomostId = null
      @showLoading(false)
    return

  addInResults : (results, direction)->
    results.reverse() if direction is DIRECTION_UP
    for result in results
      id = result._id
      continue if ~@ids.indexOf(id)
      if direction is DIRECTION_DOWN
        @ids.push id
      else
        @ids.unshift id
      @idToData[id] = result
    return

  getDisplayedTopmostId : -> $("#{@container.selector} a").first().attr("id")

  getDisplayedBottommostId : -> $("#{@container.selector} a").last().attr("id")

  renderTopPartial : ()->
    topmostId = @getDisplayedTopmostId()
    pos = @ids.indexOf(topmostId) - 1
    if pos < -1 then pos = @ids.length - 1
    while(pos > -1)
      @container.prepend(@options.formatItem(@idToData[@ids[pos]]))
      -- pos

  renderBottomPartial : ()->
    bottomostId = @getDisplayedBottommostId()
    pos = @ids.indexOf(bottomostId)
    if pos < -1 then pos = 0
    while(pos < @ids.length)
      @container.append(@options.formatItem(@idToData[@ids[pos]]))
      ++pos

(($) ->
  $.fn.mongooseEndlessScroll = (options) ->
    new MongooseEndlessScroll(this, options)
)(jQuery)

