class Wiki.Views.CloneIndex extends Backbone.View
  el:  '#clone'
  template : JST['backbone/templates/clonePreview']

  initialize: ->
    self = @
    @collection.fetch(
      success: -> self.render()
    )

  render: ->
    self = @
    $(@el).
      html($('<h1>').text("Index of clones")).
      append($('<hr>'))
    $ul = $('<ul>')
    $(@el).append($ul)
    @collection.each((clone) ->
      $ul.append(self.template(clone.toJSON()))
    )

