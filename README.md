# ticket-system

[![Build Status](https://travis-ci.org/yi/node-ticket-manager.png?branch=master)](https://travis-ci.org/yi/node-ticket-manager)
[![Dependencies Status](https://david-dm.org/yi/node-ticket-manager.png)](https://david-dm.org/yi/node-ticket-manager)


a simple ticket system contians a centeral ticket dispatcher and distributed workers. This system is written in NodeJS, runing on MongoDB

## Install
Install the module with:

```bash
npm install ticket-system
```

## Usage
```javascript
var ticket_system = require('ticket-system');
```
## HTTP API Calls:

### POST '/api/tickets/new', Admin create ticket

req.body:
```
{
  title : "title of ticket",
  owner_id : "name of owner",
  category : "category the ticket belongs to",
  content : {
    detailed : "content of ticket",
    mixed : ["data"]
  }
}
```

### PUT '/api/tickets/assign', Worker ask for a ticket assignment

req.body:
```
{
  worker : "assignment worker"
  category : "category the ticket belongs to"
}
```

### PUT '/api/tickets/:id/comment', Worker add comment to a ticket

req.body:
```
{
  name : "worker",
  kind : "info",
  content : "test comment"
}
```

### PUT '/api/tickets/:id/complete', Worker complete a ticket

req.body:
```
{
  name : "worker"
}
```

### PUT '/api/tickets/:id/giveup', Worker giveup a ticket
req.body:
```
{
  name : "worker"
}
```
## License
Copyright (c) 2014 yi
Licensed under the MIT license.
