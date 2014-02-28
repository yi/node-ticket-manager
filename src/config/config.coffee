
path = require('path')
rootPath = process.cwd()
console.log "[config::rootPath] #{rootPath}"

module.exports =
  development:
    db: 'mongodb://localhost/ticketman_dev'
    root: rootPath
    app:
      name: 'Ticket System - Dev'
    basicAuth:
      username : "dev"
      password : "123"

  test:
    db: 'mongodb://localhost/ticketman_test'
    root: rootPath
    app:
      name: 'Ticket System - Test'
    basicAuth:
      username : "test"
      password : "123"

  production:
    db: 'mongodb://localhost/ticketman'
    root: rootPath
    app:
      name: 'Ticket System'
    basicAuth:
      username : "production"
      password : "123"


