class Wiki.Views.Triple extends Backbone.View
  template : JST['backbone/templates/triple']

  decode: (str, toLower, atTo101) ->
    resBase = "http://101companies.org/resource/"
    str = decodeURIComponent(str.replace(resBase,"").replace("-3A",":").replace("Property:", "").replace(/_/g, " ").replace(/-/g, '%'))
    str = _.last(str.split("/"))
    if toLower
      firstLetter = str.substr(0, 1)
      str = firstLetter.toLowerCase() + str.substr(1)
    if atTo101
      Wiki.Utils.atTo101(str)
    else
      str

  render: ->
    self = @
    resBase = "http://101companies.org/resource/"
    rendertriple = {arrow: "&#9664;", s: "this", o: "this"}
    rendertriple.p = @decode(@model.get('predicate'), true, true)
    decodedNode = @decode(@model.get('node'), false, false)
    decodedNode_text = @decode(@model.get('node'), false, true)
    if @model.get('direction') is "IN"
      rendertriple.arrow = "&#9654;"
      rendertriple.s = decodedNode
      rendertriple.s_text = decodedNode_text
    else
      rendertriple.o = decodedNode
      rendertriple.o_text = decodedNode_text
    $(@el).append(@template(rendertriple))


