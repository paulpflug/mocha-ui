{View,TextEditorView} = require 'atom-space-pen-views'
projectManager = require "./project-manager"

class WatchModalView extends View
  @content: ->
    @div class:"patternModal", =>
      @subview 'pattern', new TextEditorView(placeholderText: "pattern")
      @div class: "status-bar", =>
        @div class: "status-bar-inlay", =>
          @div class: 'btn btn-info',click: 'save', "Save & Watch"
          @div class: "padded", outlet: 'matchesCount'


module.exports = class WatchModal
  defaultPatterns:
    """1/*.js
    1/*.coffee
    1/test/*.js
    1/test/*.coffee
    1/spec/*.js
    1/spec/*.coffee
    1/src/*.js
    1/src/*.coffee"""
  getMatches: (patterns) ->
    move =  (dir,remainingSplitted) ->
      matches = []
      current = remainingSplitted.pop()
      if remainingSplitted.length == 0
        if current.includes "*"
          if current[0] != "*"
            current = "^"+current
          current = current.replace(".","\\.").replace("*", ".+")
          pattern = new RegExp "#{current}$", "i"
          children = dir.getEntriesSync()
          for child in children
            if child.isFile() and child.getBaseName().search(pattern) > -1
              matches.push child
        else
          file = dir.getFile(current)
          if file.existsSync()
            matches.push file
      else
        if current == "*"
          children = dir.getEntriesSync()
          for child in children
            if child.isDirectory()
              matches = matches.concat move(child, remainingSplitted.slice(0))
        else
          subDir = dir.getSubdirectory(current)
          if subDir.existsSync()
            matches = matches.concat move(subDir, remainingSplitted)
      return matches
    matches = []
    projectDirs = atom.project.getDirectories()
    for pattern in patterns.split("\n")
      if pattern
        splitted = pattern.split("/").reverse()
        dirIndex = parseInt splitted.pop()
        currentDir = projectDirs[dirIndex-1]
        if currentDir and splitted.length > 0
          matches = matches.concat move(currentDir,splitted)
    return matches
  patternChanged: =>
    if @view
      @patterns = @view.pattern.getText()
      @matches = @getMatches @patterns
      @view.matchesCount.text "Matches: #{@matches.length}"
  hasPatterns: =>
    if not @patterns
      settings = projectManager.getProjectSetting()
      if settings["patterns"]
        @patterns = settings["patterns"]
    return @patterns?
  show: =>
    if not @view
      @view ?= new WatchModalView
      @view.save = @save
      @view.pattern.getModel().onDidStopChanging @patternChanged
    settings = projectManager.getProjectSetting()
    patterns = @defaultPatterns
    if settings["patterns"]
      patterns = settings["patterns"]
    @view.pattern.setText(patterns)
    @patternChanged()
    @modal ?= atom.workspace.addModalPanel(item: @view, visible: false)
    @modal.show()
    return new Promise (resolve,reject) =>
      atom.commands.add @view,
        'core:cancel': (event) =>
          reject()
          @hide()
          event.stopPropagation()
      @finished = resolve

  save: =>
    settings = {
      patterns: @patterns
    }
    projectManager.addToProjectSetting(settings)
    @finished?()
    @hide()
  watch: =>
    @clearWatcher()
    parents = []
    @matches = @getMatches @patterns
    fired = false
    for entry in @matches
      @watchers.push entry.onDidChange =>
        unless fired
          fired = true
          setTimeout (-> fired = false), 1000
          @run()



  hide: =>
    @modal?.hide()

  clearWatcher: =>
    if @watchers and @watchers.length > 0
      for watcher in @watchers
        watcher.dispose()
    @watchers = []
  destroy: ->
    @clearWatcher()
