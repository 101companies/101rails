class Wiki.Views.Triples extends Backbone.View
  template : JST['backbone/templates/triple']

  decode: (str, toLower) ->
    resBase = "http://101companies.org/resource/"
    str = decodeURIComponent(str.replace(resBase,"").replace("-3A",":").replace("Property:", "").replace("_", " ").replace(/-/g, '%'))
    str = _.last(str.split("/"))
    if toLower
      firstLetter = str.substr(0, 1)
      firstLetter.toLowerCase() + str.substr(1)
    else
      str

  render: ->
    self = @
    resBase = "http://101companies.org/resource/"
    rendertriple = {arrow: "&#9664;", s: "this", o: "this"}
    rendertriple.p = @decode(@model.get('predicate'), true)
    decodedNode = @decode(@model.get('node'), false)
    console.log(self.model.get('node'))
    console.log(Wiki.page.get('backlinks'))
    console.log (_.any(Wiki.page.get('backlinks'), (x) ->  x == decodedNode))
    if @model.get('direction') is "IN"
      rendertriple.arrow = "&#9654;"
      rendertriple.s = decodedNode
    else
      rendertriple.o = decodedNode
    $('#metasection').find('.section-content-parsed').append(@template(rendertriple))


