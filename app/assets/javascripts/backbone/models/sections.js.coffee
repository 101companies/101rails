class Wiki.Models.Section extends Backbone.Model

  defaults:
    title: ""
    content: ""

  validate: (attrs, options) ->
    `check = attrs.content.match(/==([^\r\n=])+==[^=]/g)`
    if not check
      "Validation Error: Section header missing"
    else if check.length > 1
      "Validation Error: More than one section header specified"

class Wiki.Models.Sections extends Backbone.Collection
  model: Wiki.Models.Section

