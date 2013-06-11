class Tours.Models.TourPage extends Backbone.Model

  idAttribute: 'name'

  defaults:
    title: ""
    sections: []

  #url: ->
  #  '/api/toursPage/' + @get('title')