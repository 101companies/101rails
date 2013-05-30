class Wiki.Models.Page extends Backbone.Model

  idAttribute: 'idtitle'

  initialize: ->
    @set('triples', new Wiki.Models.Triples())
    @set('sourceLinks', new Wiki.Models.SourceLinks())
    @set('resources', new Wiki.Models.Resources())

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

  parse: (res) ->
    if res.sections
      console.log(res.sections)
      res.sections = new Wiki.Models.Sections(res.sections)
    if res.history
      console.log(res.history)
      console.log("\n")
      console.log("\n")
      console.log("\n")
      res.history = new Wiki.Models.History(res.history)
    return res

  model:
      sections: Wiki.Models.Sections
      triples: Wiki.Models.Triples
      resources: Wiki.Models.Resources
      history: Wiki.Models.History

  urlRoot : ->
    "/api/pages"
