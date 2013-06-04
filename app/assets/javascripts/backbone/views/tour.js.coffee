class Tours.Views.Tour extends Backbone.View
  template : JST['backbone/templates/tour']

  el: '#tour'
  
  events:
    'click .tourCreateNew' : 'createNewTour'
    
  initialize: ->
    @model = Tours.tour
    @render()

  render: ->
    html = @template(title: @model.get('title'), author: @model.get('author'), pages: @model.get('pages'))
    $(@el).html(html)
    
  createNewTour: (a, b, c) ->
    console.log(@model.toJSON())