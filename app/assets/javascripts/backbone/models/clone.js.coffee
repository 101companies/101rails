class Wiki.Models.Clone extends Backbone.Model

  url: -> "/api/clones/" + @get('title')

  defaults:
    title: ""
    original: ""
    features: []
