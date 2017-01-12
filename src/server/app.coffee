net        = require 'net'
JsonSocket = require 'json-socket'


log       = require "./lib/log"
Generator = require "./lib/Generator"
serviceRegister = require "./lib/serviceRegister"

# collection of client sockets
sockets = []

# create a generator of data
persons = new Generator [ "first", "last", "gender", "birthday", "age", "ssn"]

# distribute data over the websockets
persons.on "data", (data) ->
	data.timestamp = Date.now()
	socket.write JSON.stringify(data) for socket in sockets

persons.start()

server = net.createServer (socket) ->
  sockets.push socket
  log.info "Socket connected, #{sockets.length} client(s) active"

  socket.on 'end', () ->
    sockets.splice sockets.indexOf(socket), 1
    log.info "Socket disconnected, #{sockets.length} client(s) active"

server.on 'error', (err) ->
  throw err;

server.listen port: 0, host: 'localhost', () ->
  address = server.address()
  console.log 'Server is listening on', address.address + ':' + address.port
  serviceRegister address.port

server.on 'error', ->
	log.error "Something went wrong:", error
