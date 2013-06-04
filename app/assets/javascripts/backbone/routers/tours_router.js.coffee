class Tours.Routers.ToursRouter extends Backbone.Router
  routes:
    "*actions" : "default"

  initialize: (ViewClass) ->
    @ViewClass = ViewClass

  default: (x) ->
    new @ViewClass()