class Wiki.Views.Clone extends Backbone.View
  el:  '#clone'
  template : JST['backbone/templates/clone']

  events:
    'click #remove' : 'remove'

  initialize: ->
    self = @
    @model.fetch(
      success: -> self.render()
    )

  render: ->
    $(@el).append(@template(@model.toJSON()))

  remove: ->
    @model.destroy(
      success: -> window.location = "/clones/"
    )
