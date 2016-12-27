log   = require "./log"
http  = require 'http'

# Run `consul agent -dev` to run Service Registry

serviceRegistry = {
    host: 'localhost'
    port: 8500
    servicePath: '/vi/catalog/service'
    registerPath: '/v1/catalog/register'
    deregisterPath: '/v1/catalog/deregister'

    datacenter: 'dc1'
    node: 'foobar'
    serviceID: 'netserver'
}

deregisterBody = {
  "Datacenter": serviceRegistry.datacenter
  "Node": serviceRegistry.node
  "ServiceID": serviceRegistry.serviceID
}

registerBody = {
  "Datacenter": "dc1"
  "Node": "foobar"
  "Address": "localhost"
  "Service": {
    "ID": serviceRegistry.serviceID + "ID"
    "Service": serviceRegistry.serviceID
    "Tags": [
      "primary"
      "v1"
    ],
    "Address": "localhost"
    "Port": 8000
  }
  "Check": {
    "Node": "foobar"
    "CheckID": "service:" + serviceRegistry.serviceID + "ID"
    "Name": "Redis health check"
    "Notes": "Script based health check"
    "Status": "passing"
    "ServiceID": serviceRegistry.serviceID + "ID"
  }
}

class ServiceRegistry
  @deregister: (callback) ->
    log.info 'Deregitering lost net servers...'
    options = {
      hostname: serviceRegistry.hostname
      port: serviceRegistry.port
      path: serviceRegistry.deregisterPath
      method: 'PUT'
      headers: {
        'Content-Type' : 'application/json'
      }
    }

    request = http.request options, (response) ->
      log.info 'Deregistered net servers successfully' if response.statusCode is 200
      callback()
    request.write JSON.stringify deregisterBody
    request.end()

  @register: (host, port) ->
    log.info 'Regestering net server'

    options = {
      hostname: serviceRegistry.hostname
      port: serviceRegistry.port
      path: serviceRegistry.registerPath
      method: 'PUT'
      headers: {
        'Content-Type' : 'application/json'
      }
    }

    registerBody.Service.Address = host
    registerBody.Service.Port = port

    request = http.request options, (response) ->
       if response.statusCode is 200
         log.info 'Registered net server successfully'
       else
        log.info response.statusMessage
    request.write JSON.stringify registerBody
    request.end()

  @findNetServer: (service) ->
    log.info 'Getting net server host address'

    options = {
      hostname: serviceRegistry.hostname
      port: serviceRegistry.port
      path: serviceRegistry.servicePath + "/" + service
      method: 'GET'
    }


    request = http.request options, (response) ->
      if response.statusCode is 200
        log.info response
      else
       log.info response.statusMessage
    request.end()

module.exports = ServiceRegistry
