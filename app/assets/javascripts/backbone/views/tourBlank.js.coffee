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
    
  createNewTour: (a) ->
 

    @newTour = new Tours.Models.Tour(title: @title)
    @newTour.save({
      author: $('#author').val(), 
      pages: $("#pages").val()
    })
    console.log(@newTour.toJSON())
    @newTour.save()
    window.location.reload()
