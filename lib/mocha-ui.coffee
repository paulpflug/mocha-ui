
mochaUiView = null
MochaUiView = null

mochaUri = 'package://mocha-ui'

createMochaUiView = ->
  MochaUiView ?= require './mocha-ui-view'
  mochaUiView = new MochaUiView

mochaUiOpener = (uri) ->
  if uri.startsWith(mochaUri)
    mochaUiView ?= createMochaUiView()
    return mochaUiView

disposables = null

module.exports =
  activate: ->
    if not CompositeDisposable?
      {CompositeDisposable} = require 'atom'
    disposables = new CompositeDisposable
    disposables.add atom.workspace.addOpener mochaUiOpener
    disposables.add atom.commands.add 'atom-workspace',
      'mocha-ui:open': ->
        atom.workspace.open(mochaUri)

  deactivate: ->
    disposables?.dispose()
  serialize: ->
