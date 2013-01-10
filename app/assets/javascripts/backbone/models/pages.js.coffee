class Wiki.Models.Page extends Backbone.Model

  idAttribute: 'title'

  defaults:
    title: ""
    categories: []
    sections: []
    backlinks: []
    triples: []

  model:
  	sections: Wiki.Models.Sections

  urlRoot : ->
    "/api/pages"
