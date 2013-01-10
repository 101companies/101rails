class Wiki.Models.Triple extends Backbone.Model

  defaults:
    direction: ""
    predicate: ""
    node: ""

class Wiki.Models.Triples extends Backbone.Collection
  model: Wiki.Models.Triple
  urlBase:  'http://sl-mac.uni-koblenz.de:8081/org.softlang.semanticendpoint/doQuery?method=getResourceTriples&resource='


