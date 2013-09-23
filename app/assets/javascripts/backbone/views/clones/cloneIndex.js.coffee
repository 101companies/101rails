class Wiki.Views.CloneIndex extends Backbone.View
  el:  '#clone'
  template : JST['backbone/templates/cloneIndex']

  initialize: ->
    self = @
    @collection.fetch(
      success: -> self.render()
    )

  render: ->
    $(@el).append(@template(models: @collection.toJSON()))
