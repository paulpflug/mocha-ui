{View,TextEditorView} = require 'atom-space-pen-views'
projectManager = require "./project-manager"

module.exports = class ActionBarView extends View
  @content: ->
    @div =>
      @div class:'btn-group', =>
        @div
          class: 'btn btn-info'
          click: 'run'
          "Run"
        @div class: 'btn btn-info',click: 'watch',outlet: 'watchbtn', "Watch"
        @div
          class: 'btn btn-info hidden'
          click: 'watchpattern'
          outlet: 'watchpatternbtn'
          "Change watch pattern"
        @div
          class: 'btn btn-info hidden'
          click: 'unwatch'
          outlet: 'unwatchbtn'
          "Unwatch"
        @div class: 'btn btn-info',click: 'showPathModal', "Change directory"
      @div class: 'inline-block filter', =>
        @subview 'filter',
          new TextEditorView(mini: true,placeholderText: "filter")
      @div class: 'inline-block env', =>
        @subview 'environment',
          new TextEditorView(mini: true,placeholderText: "environment")

  initialize: (mocha) ->
    @mocha = mocha
    @settings = projectManager.getProjectSetting()
    @settings = {} if not @settings
    if @settings["path"]
      @mocha.setPath @settings["path"]
    if @settings["filter"]
      @filter.setText @settings["filter"]
    if @settings["environment"]
      @environment.setText @settings["environment"]
  setMochaPath: (path) =>
    @settings["path"] = path
    projectManager.addToProjectSetting(@settings,false)
    @mocha.setPath(path)
    @run()

  showPathModal: ->
    if @pathChangeModal
      @pathChangeModal.show()

  run: =>
    @mochaResults.reset()
    @settings["environment"] = @environment.getText()
    @settings["filter"] = @filter.getText()
    projectManager.addToProjectSetting(@settings,false)
    envString = @settings["environment"]
    env = {}
    if envString
      for item in envString.split(";")
        splitted = item.split("=")
        if splitted.length == 2
          env[splitted[0]] = splitted[1]
    @mocha.run({filter:@settings["filter"], env:env})
  setWatching: (status) ->
    unless status?
      if @settings["watching"]?
        status = @settings["watching"]
      else
        return
    success = false
    if status
      if @watchModal
        if not @watchModal.hasPatterns()
          @watchpattern()
        else
          @unwatchbtn.removeClass "hidden"
          @watchpatternbtn.removeClass "hidden"
          @watchbtn.addClass "hidden"
          @watchModal.watch()
          success = true
    else
      if @watchModal
        @watchModal.clearWatcher()
        success = true
        @unwatchbtn.addClass "hidden"
        @watchpatternbtn.addClass "hidden"
        @watchbtn.removeClass "hidden"
    if success
      @settings["watching"] = status
      projectManager.addToProjectSetting(@settings,false)
  watch: ->
    @setWatching(true)

  watchpattern: ->
    if @watchModal
      @watchModal.show()
      .then ->
        @setWatching(true)
      .catch ->

  unwatch: ->
    @setWatching(false)
