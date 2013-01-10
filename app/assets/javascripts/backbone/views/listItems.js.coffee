class Wiki.Views.ListItems extends Backbone.View
  template: JST['backbone/templates/listItem']

  events: {
    'click .destroy' : 'clear'
  }
  render: ->
    $backlink = $(@template(title: @model.get('title')))
    @setElement($backlink)
    $backlink

  clear: ->
    @remove()
