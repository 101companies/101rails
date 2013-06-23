class Wiki.Views.Triples extends Backbone.View

  expandableTemplate: JST['backbone/templates/expandable']
  externalTriples: []
  externalTriplesPrefixes: {}

  render: ->
    self = @
    @setElement('#metasection')
    @internalTripleCount = 0
    $(@el).find('.section-content-parsed').fadeTo(200, 1)
    $(@el).find(' .loading-indicator').hide()
    @model.fetch({
      url: self.model.url(decodeURIComponent(Wiki.pageTitle))
      success: (model) ->
        self.addAll()
    })

  is101Triple: (triple) ->
    internalPrefix = 'http://'
    triple.get('node').substring(0, internalPrefix.length) != internalPrefix

  tripleOrdering: (a,b) ->
    if a.get('predicate') < b.get('predicate')
      -1
    else if a.get('predicate') > b.get('predicate')
      1
    else if a.get('node') < b.get('node')
      -1
    else if a.get('node') > b.get('node')
      1
    else
      0

  addInternalTriple: (triple) ->
    @internalTripleCount++;
    if @internalTripleCount < 15
      el = '#metasection .section-content-parsed'
    else
      if @internalTripleCount == 15
        $(@el).find('.section-content-parsed').append(@expandableTemplate(name: "metasection-continued"))
        offset = $(@el).find('.section-content-parsed > div.triple').slice(-7)
        _.each offset, (x) ->
          $('#metasection-continued').append($(x))
      el =  '#metasection-continued'
    tripleview = new Wiki.Views.Triple(model: triple, el: el)
    tripleview.render()

  registerExternalTriple: (triple) ->
    @externalTriples.push(triple)
    split = triple.get('node').split("/")
    domain = split[2].trim()
    if not @externalTriplesPrefixes[domain]
      @externalTriplesPrefixes[domain] = {}
    if not @externalTriplesPrefixes[domain][_.last(split)]
      @externalTriplesPrefixes[domain][_.last(split)] = 1
    else
      @externalTriplesPrefixes[domain][_.last(split)]++

  addExternalTriple: (triple) ->
    split = triple.get('node').split("/")
    tripleview = new Wiki.Views.ExTriple(model: triple)
    tripleview.render(@externalTriplesPrefixes[split[2].trim()][_.last(split)] > 1)

  addTriple: (triple) ->
    if @is101Triple(triple)
      @addInternalTriple(triple)
    else
      @registerExternalTriple(triple)

  addAll: ->
    self = @
    $(@el).find('.section-content-parsed').html('')
    $.each @model.models.sort(self.tripleOrdering), (i, triple) ->
      self.addTriple(triple)
    $.each @externalTriples, (i, triple) ->
      self.addExternalTriple(triple)

