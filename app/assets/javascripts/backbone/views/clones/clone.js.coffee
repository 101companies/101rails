class Wiki.Views.Clone extends Backbone.View
  el:  '#clone'
  template : JST['backbone/templates/clone']

  events:
    'click #remove' : 'remove'
    'click #confirm' : 'confirm'

  initialize: ->
    self = @
    @model.fetch(
      success: -> self.render()
    )

  render: ->
    $(@el).html(@template(@model.toJSON()))

  remove: ->
    @model.destroy(
      success: -> window.location = '/clones'
    )

  confirm: ->
    self = @
    @model.set('status', 'confirmed')
    @model.save({}, success: -> self.render())
