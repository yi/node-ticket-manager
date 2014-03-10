
class MongooseEndlessScroll

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


  constructor: (options) ->
    @options = $.extend({}, DEFAULTS , options)
    @container = $(options.container)
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
    console.log "[jquery.mongoose-endless-scroll::fetchNext] @options.inflowPixels:#{@options.inflowPixels}"
    $(window).scrollTop($(document).height() - $(window).height() - @options.inflowPixels)
    return if @isFecthing

  fetchPrev: ->
    console.log "[jquery.mongoose-endless-scroll::fetchPrev] "
    top =$(window).position()
    console.dir top

    console.log "[jquery.mongoose-endless-scroll::=======] top:#{top}"

    $(window).animate({scrollTop:top}, @options.inflowPixels)
    #$(window).scrollTop(@options.inflowPixels)
    return if @isFecthing

  fetch : (direction)->



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

