class Tours.Views.ToursPreview extends Backbone.View
  template : JST['backbone/templates/toursPreview']

  el: '#tours'
  
  events:
    'click .tourDelete' : 'deleteTour'
    'click .tourStart' : 'startTour'
    
  initialize: ->
    #@model = Tours.tour

  render: ->
    return @template(title: @model.get('title'), author: @model.get('author'), numOfPages: @model.get('pages').length)

  deleteTour: (a) ->
    tourItem = a.currentTarget.parentNode ;
    tourId = tourItem.id
    if (confirm("Do you really want to remove \n"+tourId))
      tour = new Tours.Models.Tour(title: tourId)
      console.log(tour.toJSON())
      tour.destroy()
      tourItem.remove()
    

  startTour: (a) ->
    console.log("not yet implemented")
