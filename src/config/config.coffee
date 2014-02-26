
path = require('path')
rootPath = process.cwd()
console.log "[config::rootPath] #{rootPath}"

module.exports =
  development:
    db: 'mongodb://localhost/ticket_mgr_dev'
    root: rootPath
    app:
      name: 'Ticket System - Dev'

  test:
    db: 'mongodb://localhost/ticket_mgr_test'
    root: rootPath
    app:
      name: 'Ticket System - Test'

  production:
    db: 'mongodb://localhost/ticket_mgr'
    root: rootPath
    app:
      name: 'Ticket System - Test'


