class Wiki.Routers.ClonesRouter extends Backbone.Router
  routes:
    "clones" : 'index'
    "clones/new" : "create"
    "clones/check/:title" : "check"

  index: ->
    new Wiki.Views.CloneIndex(collection: new Wiki.Models.Clones())

  create: ->
    new Wiki.Views.CloneCreate()

  check: (title) ->
    new Wiki.Views.Clone(model: new Wiki.Models.Clone(title: title))



