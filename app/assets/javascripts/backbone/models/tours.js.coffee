class Tours.Models.TourPage extends Backbone.Model

  idAttribute: 'name'

  defaults:
    title: ""
    sections: []

<<<<<<< HEAD
  #url: ->
  #  '/api/toursPage/' + @get('title')
=======
  url: ->
    '/api/tours/' + @get('title')

class Tours.Models.ToursList extends Backbone.Collection
  model: Tours.Models.Tour

  url: ->
    '/api/tours/' + @get('title')
>>>>>>> 8f9631d705c4fe41b6ef64fb00fe5e6ac7feafb7
