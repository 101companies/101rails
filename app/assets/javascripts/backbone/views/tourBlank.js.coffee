class Tours.Views.TourBlank extends Backbone.View
  template : JST['backbone/templates/tourBlank']

  el: '#tour'
  
  events:
    'click .tourCreateNew' : 'createNewTour'
    
  initialize: ->
    @title = Tours.title
    @render()

  render: ->
    html = @template(title: @title)
    #html = @template(title: @model.get('title'), author: @model.get('author'), pages: @model.get('pages'))
    #html = @template(title: @model.get('title'))
    $(@el).html(html)
    
  createNewTour: (a, b, c) ->
    newTour = new Tours.Models.Tour(title: @title)
    console.log(newTour.toJSON())
    newTour.initialize(title: newTour.get('title'), author: newTour.get('author'), pages: newTour.get('pages'))
    newTour.save()
