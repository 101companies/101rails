class Wiki.Models.Triple extends Backbone.Model

  defaults:
    direction: ""
    predicate: ""
    node: ""

class Wiki.Models.Triples extends Backbone.Collection
  model: Wiki.Models.Triple
  urlBase:  'http://triples.101companies.org/org.softlang.semanticendpoint/doQuery?method=getResourceTriples&resource='


