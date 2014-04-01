class Wiki.Views.Triple extends Backbone.View
  template : JST['backbone/templates/triple']

  decode: (str) ->
    resBase = "http://101companies.org/resource/"

    str = str.replace(resBase,"")
        .replace("-3A",":")
        .replace("Property:", "")
        .replace(/_/g, " ")
    str = decodeURIComponent(str)
    str

  render: ->
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


