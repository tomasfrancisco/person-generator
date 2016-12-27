net        = require 'net'
JsonSocket = require 'json-socket'


log       = require "./lib/log"
Generator = require "./lib/Generator"
ServiceRegistry = require "./lib/ServiceRegistry"

# collection of client sockets
sockets = []

# create a generator of data
persons = new Generator [ "first", "last", "gender", "birthday", "age", "ssn"]

# distribute data over the websockets
persons.on "data", (data) ->
	data.timestamp = Date.now()
	socket.sendMessage data for socket in sockets

persons.start()


ServiceRegistry.deregister () ->
  # Server
  server = net.createServer (socket) ->
      socket = new JsonSocket socket

      sockets.push socket
      log.info "Socket connected, #{sockets.length} client(s) active"

  server.on 'error', (err) ->
      throw err;

  server.listen port: 4000, host: 'localhost', () ->
      address = server.address()
      console.log 'Server is listening on', address.address + ':' + address.port
      ServiceRegistry.register address.address, address.port

  server.on "disconnect", ->
  		sockets.splice sockets.indexOf(socket), 1
  		log.info "Socket disconnected, #{sockets.length} client(s) active"
