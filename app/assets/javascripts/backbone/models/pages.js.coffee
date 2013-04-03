class Wiki.Models.Page extends Backbone.Model

  idAttribute: 'title'

  defaults:
    title: ""
    categories: []
    sections: []
    backlinks: []
    triples: []
    history: null
    content: ''                       # in case the entire page is stored


  model:
      sections: Wiki.Models.Sections

  urlRoot : ->
    "/api/pages"
