class Wiki.Models.SourceLink extends Backbone.Model

  defaults:
    link: ""
    name: ""

class Wiki.Models.SourceLinks extends Backbone.Collection
  model: Wiki.Models.SourceLink
  urlBase:  'http://worker.101companies.org/services/sourceLinks/'

