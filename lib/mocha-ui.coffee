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

disposable = null

module.exports =
  activate: ->
    disposable = atom.workspace.addOpener mochaUiOpener
    atom.commands.add 'atom-workspace',
      'mocha-ui:open': ->
        atom.workspace.open(mochaUri)

  deactivate: ->
    disposable?()

  serialize: ->
