{View,$} = require 'atom-space-pen-views'
class PathsModalView extends View
  @content: ->
    @div class:'select-list', =>
      @ol class:'list-group', outlet:"list"

  initialize: ->
    atom.commands.add @element,
      'core:move-up': (event) =>
        @selectPreviousItemView()
        event.stopPropagation()

      'core:move-down': (event) =>
        @selectNextItemView()
        event.stopPropagation()

      'core:move-to-top': (event) =>
        @selectItemView(@list.find('li:first'))
        @list.scrollToTop()
        event.stopPropagation()

      'core:move-to-bottom': (event) =>
        @selectItemView(@list.find('li:last'))
        @list.scrollToBottom()
        event.stopPropagation()

      'core:confirm': (event) =>
        @confirmSelection()
        event.stopPropagation()

      'core:cancel': (event) =>
        @cancel()
        event.stopPropagation()

    @list.on 'mousedown', ({target}) =>
      false if target is @list[0]

    @list.on 'mousedown', 'li', (e) =>
      @selectItemView($(e.target).closest('li'))
      e.preventDefault()
      false

    @list.on 'mouseup', 'li', (e) =>
      @confirmSelection() if $(e.target).closest('li').hasClass('selected')
      e.preventDefault()
      false

  viewForItem: (item) ->
    "<li>#{item}</li>"


  confirmed: (item) ->
    console.log("#{item} was selected")

  maxItems: Infinity

  setItems: (@items=[]) ->
    @populateList()

  getSelectedItem: ->
    @getSelectedItemView().data('select-list-item')

  populateList: ->
    return unless @items?

    @list.empty()

    for i in [0...Math.min(@items.length, @maxItems)]
      item = @items[i]
      itemView = $(@viewForItem(item))
      itemView.data('select-list-item', item)
      @list.append(itemView)

    @selectItemView(@list.find('li:first'))


  ###
  Section: Private
  ###

  selectPreviousItemView: ->
    view = @getSelectedItemView().prev()
    view = @list.find('li:last') unless view.length
    @selectItemView(view)

  selectNextItemView: ->
    view = @getSelectedItemView().next()
    view = @list.find('li:first') unless view.length
    @selectItemView(view)

  selectItemView: (view) ->
    return unless view.length
    @list.find('.selected').removeClass('selected')
    view.addClass('selected')
    @scrollToItemView(view)

  scrollToItemView: (view) ->
    scrollTop = @list.scrollTop()
    desiredTop = view.position().top + scrollTop
    desiredBottom = desiredTop + view.outerHeight()

    if desiredTop < scrollTop
      @list.scrollTop(desiredTop)
    else if desiredBottom > @list.scrollBottom()
      @list.scrollBottom(desiredBottom)

  getSelectedItemView: ->
    @list.find('li.selected')

  confirmSelection: ->
    item = @getSelectedItem()
    if item?
      @confirmed(item)
    else
      @cancel()

module.exports = class PathChangeModal
  constructor: ->
    @view ?= new PathsModalView
    @view.confirmed = (item) =>
      @confirmed(item)
      @modal.hide()
    @view.cancel =  =>
      @modal.hide()
    @modal ?= atom.workspace.addModalPanel(item: @view, visible: false)
  show: ->
    @view.setItems(atom.project.getPaths())
    @modal.show()

  confirmed: (item) ->
    console.log "#{item} selected"
