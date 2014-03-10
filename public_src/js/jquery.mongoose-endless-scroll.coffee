
class MongooseEndlessScroll

  constructor: (options) ->
    @url = options.url
    @pageSequenceToBeforeAfter = {}

  content : (fireSequence, pageSequence, scrollDirection) ->
    console.log "[jquery.mongoose-endless-scroll::content] %j:", arguments
    #return false

  callback: (fireSequence, pageSequence, scrollDirection) ->
    console.log "[jquery.mongoose-endless-scroll::callback] %j:", arguments
    #return false

  ceaseFire: (fireSequence, pageSequence, scrollDirection) ->
    return false

(($) ->
  $.fn.mongooseEndlessScroll = (options) ->
    m = new MongooseEndlessScroll(options)
    options.content = m.content
    options.callback = m.callback
    options.ceaseFire= m.ceaseFire
    $(this).endlessScroll(options)
)(jQuery)

