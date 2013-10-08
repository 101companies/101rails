class Wiki.Views.History extends Backbone.View
  el: '#history'
  template : JST['backbone/templates/history']

  initialize: ->
    @render()

  render: ->
    self = @
    $(@el).html(@template(model: self.model.toJSON()))
