
mochaUiView = null
MochaUiView = null
log = ->
logger = -> ->
reloader = null

pkgName = "mocha-ui"
mochaUri = 'package://mocha-ui'

createMochaUiView = ->
  MochaUiView ?= require './mocha-ui-view'
  mochaUiView = new MochaUiView(logger)

mochaUiOpener = (uri) ->
  if uri.startsWith(mochaUri)
    mochaUiView ?= createMochaUiView()
    return mochaUiView

disposables = null

module.exports =
  config:
    debug:
      type: "integer"
      default: 0
      minimum: 0
  debug: ->
  consumeDebug: (debugSetup) ->
    logger = debugSetup(pkg: pkgName)
    log = logger("main")
    log "debug service consumed", 2
  consumeAutoreload: (reloader) ->
    reloader(pkg:pkgName)
    log "autoreload service consumed", 2
  activate: ->
    if not CompositeDisposable?
      {CompositeDisposable} = require 'atom'
    disposables = new CompositeDisposable
    disposables.add atom.workspace.addOpener mochaUiOpener
    disposables.add atom.commands.add 'atom-workspace',
      'mocha-ui:open': ->
        atom.workspace.open(mochaUri)

  deactivate: ->
    log "deactivating"
    disposables?.dispose()
    mochaUiView?.destroy()
    mochaUiView = null
    MochaUiView = null
    reloader?.dispose()
    reload = null
    log = null

  serialize: ->
