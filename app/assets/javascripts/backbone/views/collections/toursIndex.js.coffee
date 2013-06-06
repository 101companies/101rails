class Tours.Views.Index extends Backbone.View

  initialize: ->
    @render()

  render: ->
    self = @
    _.each(Tours.tours.models, self.addTour)

  addTour: (tour) ->
   view = new Tours.Views.ToursPreview(model: tour)
   view.render()

