class Wiki.Views.Resource extends Backbone.View
  resourceTemplate : JST['backbone/templates/resource']
  resourceBoxTemplate : JST['backbone/templates/resourcebox']

  render: ->
    self = @
    debugger;
    if @model.get('isLinkable')
      $('#resources').show()
      @setElement($(@resourceTemplate(@model.toJSON())))
      $.each ['primary', 'secondary'], (i, cat) ->
        $.each self.model.get(cat), (i, target) ->
          console.log(target)
          $(self.el).find('.resourcebar').append($(self.resourceBoxTemplate(cat:cat, link:target)))
      $('#resources').append(@el)
      $(@el).find('.resourcename').mouseenter( ->
        $(self.el).find('.resourcebar').first().collapse('show')
      )
      $(@el).mouseleave( ->
          $(self.el).find('.resourcebar').first().collapse('hide')
      )
