
mochaUiView = null
MochaUiView = null
log = null
logger = null
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
  activate: ->
    setTimeout (->
      reloaderSettings = pkg:pkgName,folders:["lib","styles"]
      try
        reloader ?= require("atom-package-reloader")(reloaderSettings)
      ),500
    unless log?
      logger = require("atom-simple-logger")(pkg:pkgName)
      log = logger("main")
      log "activating"
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
