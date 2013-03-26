class Wiki.Models.Resource extends Backbone.Model

  defaults:
    name: ""
    primary: []
    secondary: []

class Wiki.Models.Resources extends Backbone.Collection
  model: Wiki.Models.Resource
  urlBase:  'http://worker.101companies.org/services/termResources/'
