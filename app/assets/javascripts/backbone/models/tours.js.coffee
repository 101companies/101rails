class Tours.Models.TourPage extends Backbone.Model

  idAttribute: 'name'

  defaults:
    title: ""
    sections: []


class Tours.Models.ToursList extends Backbone.Collection
  model: Tours.Models.Tour

  url: ->
    '/api/tours/' + @get('title')
