class Tours.Models.Tour extends Backbone.Model

  idAttribute: 'title'

  defaults:
    title: ""
    author: ""
    pages: []

  url: ->
    '/api/tours/' + @get('title')


class Tours.Models.ToursList extends Backbone.Collection
  model: Tours.Models.Tour

  url: ->
    '/api/tours/' + @get('title')
