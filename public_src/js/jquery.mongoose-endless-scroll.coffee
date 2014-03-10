
class MongooseEndlessScroll


  content : (fireSequence, pageSequence, scrollDirection) ->
    console.log "[jquery.mongoose-endless-scroll::content] #{arguments}"
    return

  callback: (fireSequence, pageSequence, scrollDirection) ->
    console.log "[jquery.mongoose-endless-scroll::callback] #{arguments}"
    return


(($) ->
  $.fn.mongooseEndlessScroll = (options) ->
    m = new MongooseEndlessScroll()
    options.content = m.content
    options.callback = m.callback

    $(this).endlessScroll(options)
)(jQuery)

