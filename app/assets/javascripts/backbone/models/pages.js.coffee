class Wiki.Models.Page extends Backbone.Model

  initialize: ->
    @set('content', Wiki.pageContent)
    @set('nice_title', Wiki.pageNiceTitle)
    # create sections
    page_sections = []
    Wiki.pageSections.forEach (el) ->
      page_sections.push new Wiki.Models.Section (
        title: el.title,
        content: el.content,
        html_content: el.html_content
      )
    # populate sections for collection of sections
    # TODO: it was dirty
    class Sections extends Backbone.Collection
      model: Wiki.Models.Section,
      initialize: ->
        this.reset page_sections
    @set('sections', new Sections)
    @set('backlinks', Wiki.pageBacklinks)
    @set('history', new Wiki.Models.History(Wiki.pageHistory))
    page_triples = []
    Wiki.pageTriples.forEach (el) ->
      page_triples.push new Wiki.Models.Triple (
        direction: el.direction,
        node: el.node,
        predicate: el.predicate
      )
    class Triples extends Backbone.Collection
      model: Wiki.Models.Triple,
      initialize: ->
        this.reset page_triples
    @set('triples', new Triples(Wiki.pageTriples))
    @set('sourceLinks', new Wiki.Models.SourceLinks())
    @set('resources', new Wiki.Models.Resources())

  defaults:
    id: ''                           # used for renaming (i.e. change "title" but keep "idtitle" for the server to know)
    newTitle: ""
    sections: null
    backlinks: null
    triples: null
    sourceLinks: null
    resources: null
    history: null
    content: ''                       # in case the entire page is stored

  parse: (res) ->
    if res.sections
      res.sections = new Wiki.Models.Sections(res.sections)
    if res.history
      res.history = new Wiki.Models.History(res.history)
    return res

  model:
      sections: Wiki.Models.Sections
      triples: Wiki.Models.Triples
      resources: Wiki.Models.Resources
      history: Wiki.Models.History

  urlRoot : ->
    "/api/pages"
