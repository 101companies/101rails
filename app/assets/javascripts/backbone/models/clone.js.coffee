class Wiki.Models.Clone extends Backbone.Model

  url: -> "/api/clones/" + @get('title')

  defaults:
    title: ""
    status: "non-existent"
    original: ""
    features: []
