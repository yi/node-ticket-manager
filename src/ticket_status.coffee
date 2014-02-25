
ALL_STATUS = [ 'pending','processing','completed','abandoned']

module.exports =

  PENDING : 'pending'

  PROCESSING : 'processing'

  COMPLETE : 'completed'

  ABANDON : 'abandoned'

  isValid : (status)->
    return ~ALL_STATUS.indexOf status



