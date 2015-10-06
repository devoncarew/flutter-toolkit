# This is an implementation of _debugger that talks to the DartVM
# over websockets. _debugger is part of the internal atom repl.js
# package.

# .client.destroy
# .client.reqLookup(ref)
# .client.listbreakpoints
# .client.breakpoints[]
# .client.setBreakpoint(req)
# .client.step [type, count]
# .client.continue
# .client.getScriptById
# .client.currentScript
# .client.currentSourceLine
# .client.scripts[]
# .client.fullTrace
# .client.evaluate(expr)
# .client.on ('unhandledResponse')
# .client.on ('break')
# .client.on ('exception')
# .client.on ('error')
# .client.on ('close')
# .client.once('ready') -> callback

{EventEmitter} = require 'events'
logger = require './logger'


class Client extends EventEmitter
  constructor: ()->
    super()
    @s = null
    @iso = null
    @vm = null

    #@onReadyEvent = Event()

  connect: ->
    logger.info 'shim', 'connecting to VM...'
    @s = new WebSocket("ws://localhost:8181/ws")

    @s.onopen = (event) =>
      console.log("ws::open");

      # subscribe to events from the VM
      @s.send '{"jsonrpc": "2.0","method": "streamListen","params": {"streamId": "Debug"},"id": "streamlisten"}'

      # Collect some info about the VM here.
      @s.send '{"jsonrpc": "2.0","method": "getVM","params": {},"id": "getvm"}'

      @emit 'ready'

    @s.onmessage = (event) =>
      console.log("ws::message " + event.data)
      json = JSON.parse(event.data)
      if (json.id == 'streamlisten')
        logger.info 'shim', event.data
      else if (json.id == 'getvm')
        @vm = json
      else if (json.id == 'getiso')
        @iso = json


    @s.onclose = () =>
      console.log("ws::close");

  destroy: ->
    @s.close()

  req: (cmd) ->
    logger.info 'shim', 'req -> ' + cmd

  reqLookup: (req) ->
    logger.info 'shim', 'reqLookup'

  listbreakpoints: ->
    logger.info 'shim', 'listbreakpoints'

  breakpoints: ->
    logger.info 'shim', 'breakpoints'

  setBreakpoint: (req) ->
    logger.info 'shim', 'setBreakpoint'

  step: (type, count) ->
    logger.info 'shim', 'step ' + type

  continue: ->
    logger.info 'shim', 'continue'

  getScriptById: (id) ->
    logger.info 'shim', 'getScriptById'

  currentScript: ->
    logger.info 'shim', 'currentScript'

  currentSourceLine: ->
    logger.info 'shim', 'currentSourceLine'
    return 1;

  scripts: ->
    logger.info 'shim', 'scripts'
    return []

  fullTrace: ->
    logger.info 'shim', 'fullTrace'
    return "";

  evaluate: (expr) ->
    logger.info 'shim', 'evaluate'


exports.Client = Client
