class Wiki.Models.Page extends Backbone.Model

  idAttribute: 'title'

  defaults:
    title: ""
    sections: null
    backlinks: null
    triples: null
    sourceLinks: null
    resources: null
    history: null
    content: ''                       # in case the entire page is stored


  model:
      sections: Wiki.Models.Sections
      triples: Wiki.Models.Triples
      resources: Wiki.Models.Resources

  urlRoot : ->
    "/api/pages"
