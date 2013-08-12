class Wiki.Models.Triple extends Backbone.Model

  defaults:
    direction: ""
    predicate: ""
    node: ""

class Wiki.Models.Triples extends Backbone.Collection
  model: Wiki.Models.Triple

  fetch: (options) ->
    options.cache = false
    return Backbone.Collection.prototype.fetch.call(@, options)

  url: (title) -> '/endpoint/' + title + '/json/directions'


