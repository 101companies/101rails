class Tours.Views.ToursPreview extends Backbone.View
  template : JST['backbone/templates/toursPreview']

  render: ->
    return @template(title: @model.get('title'), author: @model.get('author'), numOfPages: @model.get('pages').length)
