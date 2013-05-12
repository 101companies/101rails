class Wiki.Models.Page extends Backbone.Model

  idAttribute: 'idtitle'

  defaults:
    idtitle: ''                           # used for renaming (i.e. change "title" but keep "idtitle" for the server to know)
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
