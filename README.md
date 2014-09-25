# ticket-system

[![Build Status](https://travis-ci.org/yi/node-ticket-manager.png?branch=master)](https://travis-ci.org/yi/node-ticket-manager)
[![Dependencies Status](https://david-dm.org/yi/node-ticket-manager.png)](https://david-dm.org/yi/node-ticket-manager)


A simple pull-based job/ticket system contians a centeral ticket dispatcher and distributed workers. This system is written in NodeJS, runing on MongoDB

This system consists of following 3 parts:

 * Ticketman website - a ExpressJS app display the current status of the centeral ticket system
 * TicketManager - a JS Class for create(TicketManager.issue) new ticket
 * TicketWorker - a JS Class pulls ticket from Ticketman website on a routine, it can also complete/giveup/add comment to a ticket. The TicketWorker instance works on one ticket at time.


## Install as NodeJS module:
Install the module with:

```bash
npm install ticketman
```

## Screenshots

### Job (Tickets) List

![Ticketman screenshot 01](https://raw.githubusercontent.com/yi/node-ticket-manager/master/public/img/ticketman_screenshot01.png "Ticketman screenshot 01")

### Ticket detail

![Ticketman screenshot 02](https://raw.githubusercontent.com/yi/node-ticket-manager/master/public/img/ticketman_screenshot02.png "Ticketman screenshot 02")


### Client-worker add comments to ticket

![Ticketman screenshot 03](https://raw.githubusercontent.com/yi/node-ticket-manager/master/public/img/ticketman_screenshot03.png "Ticketman screenshot 03")

### Manage multiple client-workers

![Ticketman screenshot 04](https://raw.githubusercontent.com/yi/node-ticket-manager/master/public/img/ticketman_screenshot04.png "Ticketman screenshot 04")


## Use the Ticketman website

 1. Download and extract the latest release from https://github.com/yi/node-ticket-manager/releases
 2. run "npm install" to install dependencies
 3. run "npm start" to start the service
 4. Open http://localhost:3456 in your web browser


## NodeJS Module Usage
```javascript
var  TicketWorker = require("ticketman").TicketWorker;
var  TicketManager = require("ticketman").TicketManager;
```

## TicketManager API

```
new TicketManager : (@name, @host, basicAuth) ->

TicketManager.issue()
// issue : (title, category, content, callback)->
```

## TicketWorker API

### Instance construction
```
  constructor: (options={}) ->
  # @param {Object} options, optionally includes:
  #     options.name
  #     options.id
  #     options.consumerSecret
  #     options.host
  #     options.category
  #     options.timeout : ticket processing timeout in ms
  #     options.interval : self checking interval
  #     options.basicAuth : basicAuth
  #
```

### Evnets:

 * on "new ticket", listener signature: eventListener(ticket)
 * on "complete", listener signature: eventListener(ticket)
 * on "giveup", listener signature: eventListener(ticket)

### Instance Methods

 * complete : ()->
 * update : (message, kind='default')->
 * giveup: (reason)->

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
