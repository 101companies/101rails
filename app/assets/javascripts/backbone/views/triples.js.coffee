class Wiki.Views.Triples extends Backbone.View

  initialize: ->
    @model.bind('reset', @render, @)

  is101Triple: (triple) ->
    internalPrefix = 'http://101companies.org/'
    triple.get('node').substring(0, internalPrefix.length) == internalPrefix

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

  render: ->
    @internalTripleCount = 0
    @addAll()

  addInternalTriple: (triple) ->
    if @internalTripleCount < 13
      el = '#metasection .section-content-parsed'
    else
      if @internalTripleCount == 13
        $('#metasection').append(@expandableTemplate(name: "metasection-continued"))
      el = "#metasection-continued"
    tripleview = new Wiki.Views.Triple(model: triple, el: el)
    tripleview.render()

  addExternalTriple: (triple) ->
    tripleview = new Wiki.Views.ExTriple(model: triple)
    tripleview.render()

  addTriple: (triple) ->
    if @is101Triple(triple)
      @internalTripleCount++;
      @addInternalTriple(triple)
    else
      @addExternalTriple(triple)

  addAll: ->
    self = @
    $('#metasection .section-content-parsed').html('')
    $.each @model.models.sort(self.tripleOrdering), (i, triple) ->
      self.addTriple(triple)

