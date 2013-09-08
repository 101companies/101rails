class Tours.Views.ToursPreview extends Backbone.View
  template : JST['backbone/templates/toursPreview']

  events:
    'click .tourDelete' : 'deleteTour'
    'click .tourStart' : 'startTour'

  initialize: ->
    #@model = Tours.tour

  render: ->
    html = @template(title: @model.get('title'), author: @model.get('author'), numOfPages: @model.get('pages').length)
    $("#tourlist").append(html)
    @setElement('#' + @model.get('title').replace(/\s/g, '_'))


  deleteTour: (a) ->
    self = @
    if (confirm("Do you really want to remove \n"+ @model.get('title')))
      @model.destroy(
        success: ->
          $(self.el).remove()
      )

  isAdmin: ->
    _.contains(Wiki.currentUser.get('actions'), "Edit")

  startTour: (a) ->
    console.log("not yet implemented")