class Wiki.Routers.ClonesRouter extends Backbone.Router
  routes:
    "clones/new" : "create"
    "clones/check/:title" : "check"

  create: ->
    new Wiki.Views.CloneCreate()

  check: (title) ->
    new Wiki.Views.Clone(model: new Wiki.Models.Clone(title: title))



