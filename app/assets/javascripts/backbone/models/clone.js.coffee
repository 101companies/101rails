class Wiki.Models.Clone extends Backbone.Model

  url: -> "/api/clones/" + @get('title')

  idAttribute: '_id'

  defaults:
    title: ""
    status: "non-existent"
    original: ""
    features: []
    minusfeatures: []

class Wiki.Models.Clones extends Backbone.Collection

  model: Wiki.Models.Clone
  url: "/api/clones"
