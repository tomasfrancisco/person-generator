log   = require "./log"
http  = require 'http'
consul = require('consul')()

timeout = null

serviceRegister = (port) ->
  consul.agent.service.register name: 'person-generator', port: port, (err) ->
    if err
      if err.code is 'ECONNREFUSED'
        log.warn 'Cannot connect to service registry. Trying again in 3 sec...'
        timeout = setTimeout serviceRegister, 3000, port
      else
        throw err
    else
      log.info 'Service registered successfully.'
      clearTimeout(timeout) if timeout isnt null

module.exports = serviceRegister
