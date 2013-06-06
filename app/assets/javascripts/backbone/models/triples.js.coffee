class Wiki.Models.Triple extends Backbone.Model

  defaults:
    direction: ""
    predicate: ""
    node: ""

class Wiki.Models.Triples extends Backbone.Collection
  model: Wiki.Models.Triple
  url: (title) -> 'http://localhost:3000/endpoint/' + title + '/json/directions'


