class Wiki.Views.Triple extends Backbone.View
  template : JST['backbone/templates/triple']

  decode: (str, toLower, decodeURI, atTo101) ->
    resBase = "http://101companies.org/resource/"

    str = str.replace(resBase,"")
        .replace("-3A",":")
        .replace("Property:", "")
        .replace(/_/g, " ")
    if decodeURI
      str = decodeURIComponent(str)
    str = _.last(str.split("/"))
    str1 = str.substr(0, 1)
    str1 = if toLower then str1.toLowerCase() else str1.toUpperCase()
    str = str1 + str.substr(1)
    if atTo101
      Wiki.Utils.atTo101(str)
    else
      str

  render: ->
    self = @
    resBase = "http://101companies.org/resource/"
    rendertriple = {arrow: "&#9664;", s: "this", o: "this"}
    rendertriple.p = @decode(@model.get('predicate'))
    decodedNode = @decode(@model.get('node'))
    decodedNode_text = @decode(@model.get('node'))
    if @model.get('direction') is "IN"
      rendertriple.arrow = "&#9654;"
      rendertriple.s = decodedNode
      rendertriple.s_text = decodedNode_text
    else
      rendertriple.o = decodedNode
      rendertriple.o_text = decodedNode_text
    $(@el).append(@template(rendertriple))


