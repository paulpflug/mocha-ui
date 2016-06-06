{View} = require 'atom-space-pen-views'
class ListItem extends View
  @content: (params) ->
    @li class:params.class, click: "click", =>
      if params.indent
        @span class:"indent" for i in params.indent
      if params.children
        for child in params.children
          @span class: child.class, child.text
      else
        @span params.text
  click: -> return null

module.exports = class MochaResultsView extends View
  @content: ->
    @div class: 'flex', =>
      @div class:'condensed', =>
        @ul class: 'errorlist', outlet: "errorlist"
        @ul class: 'condensedlist',outlet: "condensedlist"
      @div class:'scroller', =>
        @ul class: 'list',outlet: "list"

  initialize: (mocha) ->
    @element.hidden = true
    mocha.on "line", (line) =>
      if line == '"atom-ui-reporter" reporter not found'
        atom.notifications.addError '"atom-ui-reporter" not found',
          detail: """To install the required package, run
            npm install --save-dev atom-ui-reporter"""
      @list.append new ListItem(class: "stdout", text:line)
    mocha.on "obj", (obj) =>
      switch obj.type
        when "start"
          if @statusBar
            @statusBar.reset()
          @element.hidden = false
          return null
        when "end"
          if !@errorCount
            if @statusBar
              @statusBar.setClass "highlight-success"
            atom.notifications.addSuccess("#{@finishedCount} Tests finished successfully")
          else
            atom.notifications.addError("#{@errorCount}/#{@finishedCount} Tests failed")
          return null
        when "pass"
          obj.icon = "check"
        when "fail"
          obj.icon = "x"
          @addError()
          errorItem = new ListItem(class: "error", text:"(#{@errorCount}) #{obj.fullTitle}")
          errorItem.append("<div class='stack'></div>")
          .children("div.stack")
          .text(obj.err)
          .html (index, string) ->
            return string.replace("\n","<br/>")
          @errorlist.append errorItem
        when "pending"
          obj.icon = "dash"
      @addTest()
      clicker = () => @setFilter obj.title
      createSuiteItem = (name) =>
        suiteItem = new ListItem {
          class: "suite"
          text:name
          indent: @suite
        }
        suiteclicker =  =>
          @setFilter name
        suiteItem.click = suiteclicker
        return suiteItem
      for s,i in obj.suite
        if @suite[i] and @suite[i] != s
          @suite = @suite.slice(0,i)
        if !@suite[i]
          @list.append createSuiteItem(s)
          @condensedlist.append createSuiteItem(s)
          @suite.push s
      children = []
      if obj.icon
        children.push class:"pre icon icon-#{obj.icon}",text:""
      children.push text:obj.title, class: "title"
      if obj.duration != null and obj.duration != undefined
        children.push text:"(#{obj.duration} ms)", class:"duration"
      if obj.type == "fail"
        children.push text:"(#{@errorCount})", class: "errorlink"
      listItem = new ListItem {
        class: obj.type
        children:children
        indent: obj.suite
      }
      listItem.click = clicker
      @list.append listItem
      condensedItem = new ListItem {
        class: obj.type
      }
      condensedItem.click = clicker
      tooltip = atom.tooltips.add condensedItem, {title:obj.title}
      @tooltips.push tooltip
      @condensedlist.append condensedItem
  setFilter: (text) ->
    if @statusBar and @statusBar.actionBar
      @statusBar.actionBar.filter.setText(text)
      @statusBar.actionBar.run()
  addError: ->
    @errorCount++
    if @statusBar
      @statusBar.errors.text "Error#{if @errorCount > 1 then 's' else ''}: #{@errorCount}"
      @statusBar.setClass "highlight-error"
  addTest: ->
    @finishedCount++
    if @statusBar
      @statusBar.progress.attr "value", @finishedCount
  clearTooltips: ->
    if @tooltips and @tooltips.length > 0
      for tooltips in @tooltips
        tooltips.dispose()
    @tooltips = []
  reset: () ->
    @element.hidden = true
    @clearTooltips()
    @list.children("li").remove()
    @errorlist.children("li").remove()
    @condensedlist.children("li").remove()
    if @statusBar
      @statusBar.reset()
    @suite = []
    @indent = 0
    @errorCount = 0
    @finishedCount = 0
  destroy: () ->
    @clearTooltips()
