class Wiki.Views.Resources extends Backbone.View
  resourceTemplate : JST['backbone/templates/resource']
  resourceBoxTemplate : JST['backbone/templates/resourcebox']

  render: ->
    self = @
    if @model.get('isLinkable')
      @setElement($(@resourceTemplate(@model.toJSON())))
      $.each ['primary', 'secondary'], (i, cat) ->
        $.each self.model.get(cat), (i, target) ->
          $(self.el).find('.resourcebar').append($(self.resourceBoxTemplate(cat:cat, link:target)).tooltip("show"))
      $('#resources').append(@el)
