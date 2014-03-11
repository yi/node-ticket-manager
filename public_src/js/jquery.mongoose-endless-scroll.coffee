
class MongooseEndlessScroll

  DIRECTION_NEXT = "after"

  DIRECTION_PREV = "before"

  DEFAULTS =
    #pagesToKeep:       null
    inflowPixels:      50
    #fireOnce:          true
    #fireDelay:         150
    #loader:            'Loading...'
    #content:           ''
    #insertBefore:      null
    #insertAfter:       null
    intervalFrequency: 250
    #ceaseFireOnEmpty:  true
    #resetCounter:      -> false
    #callback:          -> true
    #ceaseFire:         -> false


  constructor: (scope, options) ->
    @options = $.extend({}, DEFAULTS , options)
    @container = $(options.container)

    @elLoadingPrev = @options.elLoadingPrev
    @elLoadingPrev.click => @fetchPrev()
    @elLoadingNext = @options.elLoadingNext
    @elLoadingNext.click => @fetchNext()

    @upmonstId = null
    @downmonstId = null

    #kv hash, key: record id, value: record data
    @idToData = {}

    # ordered record id
    @ids = []

    @isFecthing = false
    console.log "[jquery.mongoose-endless-scroll::options]"
    console.dir options
    #@serviceUrl  = options.serviceUrl
    #@pageSequenceToBeforeAfter = {}

    scrollListener = =>
      $(window).one "scroll", =>
        if ($(window).scrollTop() >= $(document).height() - $(window).height() - @options.inflowPixels)
          @fetchNext()
        else if $(window).scrollTop() <= @options.inflowPixels
          @fetchPrev()
        setTimeout scrollListener, @options.intervalFrequency

    $(document).ready => scrollListener()

  fetchNext : ->
    #console.log "[jquery.mongoose-endless-scroll::fetchNext] @options.inflowPixels:#{@options.inflowPixels}"
    $(window).scrollTop($(document).height() - $(window).height() - @options.inflowPixels)

    data = {}
    data[DIRECTION_NEXT] = @ids[@ids.length - 1]
    @fetch data
    return

  fetchPrev: ->
    #console.log "[jquery.mongoose-endless-scroll::fetchPrev] "
    $(window).scrollTop(@options.inflowPixels)

    data = {}
    data[DIRECTION_PREV] = @ids[0]
    @fetch data
    return

  fetch : (data)->
    #console.log "[jquery.mongoose-endless-scroll::fetch] "
    #console.dir data

    if @isFecthing
      console.log "[jquery.mongoose-endless-scroll::fetch] in fetching"
      return

    if data[DIRECTION_NEXT] is @downmonstId or data[DIRECTION_PREV] is @upmonstId
      console.log "[jquery.mongoose-endless-scroll::fetch] reach boundary"
      return

    # lock on
    @isFecthing = true

    ajaxOptions =
      dataType : "json"
      url : @options.serviceUrl
      data : data
      success : (res, textStatus)=>
        console.log "[jquery.mongoose-endless-scroll::receive] textStatus:#{textStatus}, res:"
        console.dir res
        console.dir data

        # release lock
        @isFecthing = false

        # figure out direction
        currentDirection = if data.after? then DIRECTION_NEXT else DIRECTION_PREV
        console.log "[jquery.mongoose-endless-scroll::receive] currentDirection:#{currentDirection}"

        # validate result
        unless Array.isArray(res.results) and res.results.length
          # reach boundary
          if currentDirection is DIRECTION_NEXT
            @downmonstId = data.after
          else
            @upmonstId = data.before
          return

        @addInResults(res.results, currentDirection)

        if currentDirection is DIRECTION_NEXT then @renderBottomPartial() else @renderTopPartial()

        # render partial
        return

      error : (jqXHR, textStatus, err)=>
        console.log "[jquery.mongoose-endless-scroll::error] err:#{err}"
        @container.trigger("mescroll_error", err)
        @isFecthing = false
        return

    $.ajax ajaxOptions
    return

  addInResults : (results, direction)->
    for result in results
      id = result._id
      continue if ~@ids.indexOf(id)
      if direction is DIRECTION_NEXT
        @ids.push id
      else
        @ids.unshift id
      @idToData[id] = result
    return

  getDisplayedTopmostId : -> $("#{@container.selector} a").first().attr("id")

  getDisplayedBottommostId : -> $("#{@container.selector} a").last().attr("id")

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

  renderTopPartial : ()->
    topmostId = @getDisplayedTopmostId()
    pos = @ids.indexOf(topmostId) - 1
    if pos < -1 then pos = @ids.length - 1
    while(pos > -1)
      @container.prepend(@formatItem(@idToData[@ids[pos]]))
      -- pos

  renderBottomPartial : ()->
    bottomostId = @getDisplayedBottommostId()
    pos = @ids.indexOf(bottomostId)
    if pos < -1 then pos = 0
    while(pos < @ids.length)
      @container.append(@formatItem(@idToData[@ids[pos]]))
      ++pos

  content : (fireSequence, pageSequence, scrollDirection) ->
    console.log "[jquery.mongoose-endless-scroll::content] %j:, serviceUrl:%j", arguments, @serviceUrl
    options =
      dataType:"json"
      url:@serviceUrl
      data:{}
      success:(data, textStatus)->
        console.log "[jquery.mongoose-endless-scroll::getJSON] data:"
        console.dir data

    $.ajax options

    #return false

  callback: (fireSequence, pageSequence, scrollDirection) ->
    console.log "[jquery.mongoose-endless-scroll::callback] %j:", arguments
    #return false

  ceaseFire: (fireSequence, pageSequence, scrollDirection) ->
    return false




(($) ->
  $.fn.mongooseEndlessScroll = (options) ->
    new MongooseEndlessScroll(this, options)

  #$.fn.mongooseEndlessScroll = (options) ->
    #m = new MongooseEndlessScroll(options)
    #options.content = m.content
    #options.callback = m.callback
    #options.ceaseFire= m.ceaseFire
    #$(this).endlessScroll(options)
)(jQuery)

