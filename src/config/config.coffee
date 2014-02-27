
path = require('path')
rootPath = process.cwd()
console.log "[config::rootPath] #{rootPath}"

module.exports =
  development:
    db: 'mongodb://localhost/ticketman_dev'
    root: rootPath
    app:
      name: 'Ticket System - Dev'

  test:
    db: 'mongodb://localhost/ticketman_test'
    root: rootPath
    app:
      name: 'Ticket System - Test'

  production:
    db: 'mongodb://localhost/ticketman'
    root: rootPath
    app:
      name: 'Ticket System'


