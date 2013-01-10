class Wiki.Views.Triples extends Backbone.View
  template : JST['backbone/templates/triple']

  decode: (str, toLower) ->
    resBase = "http://101companies.org/resource/"
    str = str.replace(resBase,"").replace("-3A",":").replace("Property:", "").replace("_", " ")
    if toLower
      firstLetter = str.substr(0, 1)
      firstLetter.toLowerCase() + str.substr(1)
    else
      str

  render: ->
    resBase = "http://101companies.org/resource/"
    rendertriple = {arrow: "&#9664;", s: "this", o: "this"}
    rendertriple.p = @decode(@model.get('predicate'), true)
    if @model.get('direction') is "IN"
      rendertriple.arrow = "&#9654;"
      rendertriple.s = @decode(@model.get('node'))
    else
      rendertriple.o = @decode(@model.get('node'))
    $('#metasection').append(@template(rendertriple))


