{$,View} = require 'atom-space-pen-views'

module.exports = class StatusbarView extends View
  @content: (actionBar)->
    @div class:'status-bar highlight', =>
      @div class:'status-bar-inlay', =>
        @subview 'actionBar', actionBar
        @progress class:'inline-block', outlet: "progress"
        @div class: 'total', outlet: "total"
        @div class: 'errors', outlet: "errors"
  initialize: ->
    @_class = "highlight"
  setClass: (newClass) ->
    if @_class != newClass
      $(@element).removeClass @_class
      $(@element).addClass newClass
      @_class = newClass
  reset: ->
    @setClass "highlight"
    @errors.text ""
    @total.text ""
    @progress.attr "value", 0
