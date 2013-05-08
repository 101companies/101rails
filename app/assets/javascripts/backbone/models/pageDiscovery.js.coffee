class Wiki.Models.PageDiscovery extends Backbone.Model

  defaults:
    title: ""
    headine: ""


  sync: (method, model, options) ->
    options.dataType = "jsonp"
    Backbone.sync(method, model, options)

  urlRoot : ->
    "http://101companies.org/resources?wikititle=" + @get('title') + "&format=jsonp"
