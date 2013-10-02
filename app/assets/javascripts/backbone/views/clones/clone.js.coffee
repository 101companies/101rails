class Wiki.Views.Clone extends Backbone.View
  el:  '#clone'
  template : JST['backbone/templates/clone']

  events:
    'click #remove' : 'remove'
    'click #confirm' : 'confirm'
    'click .prop-respond' : 'propRespond'

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

  propRespond: (e) ->
    self = @
    propagation = @model.get('propagation')
    propagation['response'] = $(e.target).val()
    @model.save({'propagation': propagation},
      success: -> self.render()
    )


  confirm: ->
    self = @
    @model.set('status', 'confirmed')
    @model.save({},
      success: -> self.render()
    )
