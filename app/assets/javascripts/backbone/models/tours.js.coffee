class Tours.Models.Tour extends Backbone.Model

  idAttribute: 'title'

  defaults:
    title: ""
    author: ""
    pages: []

  urlRoot : ->
    "/api/tours"

class Tours.Models.ToursList extends Backbone.Collection
  model: Tours.Models.Tour
