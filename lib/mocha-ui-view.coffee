{View} = require 'atom-space-pen-views'

PathChangeModal = require "./path-change-modal"
MochaResultsView = require "./mocha-results-view"
StatusBarView = require "./status-bar-view"
ActionBarView = require "./action-bar-view"
PathChangeModal = require "./path-change-modal"
WatchModal = require "./watch-modal"

Mocha = require "./mocha-interface"
mocha = null


class MochaUiView extends View
  @content: ->
    @div class:'panel mocha-ui', outlet: "panel", =>
      @subview 'statusBar', new StatusBarView(new ActionBarView(mocha))
      @subview 'mochaResults', new MochaResultsView(mocha)
  initialize: (state) ->
    @mochaResults.statusBar = @statusBar
    @actionBar = @statusBar.actionBar
    @actionBar.mochaResults = @mochaResults
    @actionBar.setMochaPath(atom.project.getPaths()[0])
    @pathChangeModal = new PathChangeModal
    @actionBar.pathChangeModal = @pathChangeModal
    @pathChangeModal.confirmed = @actionBar.setMochaPath
    @watchModal = new WatchModal
    @actionBar.watchModal = @watchModal
    @watchModal.run = @actionBar.run
    @actionBar.setWatching()
  destroy: ->
    @watchModal.destroy()
module.exports = class MochaUiSession
  @deserialize: ->
    new MochaUiSession
  constructor: (logger) ->
    mocha = new Mocha
    @log = logger("session")
  atom.deserializers.add @
  serialize: ->
    deserializer: 'MochaUiSession'
    version: 1
    state: @state
  destroy: ->
    @log "destroying"
  getViewClass: ->
    @log "ViewClass delivered"
    return MochaUiView

  getTitle: -> "Mocha UI"

  getURI: -> "package://mocha-ui"
