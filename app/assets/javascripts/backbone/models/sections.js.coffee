class Wiki.Models.Section extends Backbone.Model

  defaults:
    title: ""
    content: ""

class Wiki.Models.Sections extends Backbone.Collection
  model: Wiki.Models.Section
