class Wiki.Models.Section extends Backbone.Model

  defaults:
    title: ""
    content: ""

  validate: (attrs, options) ->
    codeRegex = /\<syntaxhighlight((.|\s)*?)\<\/syntaxhighlight\>/g
    sectionRegex = /(==([^\r\n=])+==)(\r|\n|[^=])/g
    check = attrs.content.replace(codeRegex, '').match(sectionRegex)
    if not check
      "Validation Error: Section header missing"
    else if check.length > 1
      "Validation Error: More than one section header specified"

class Wiki.Models.Sections extends Backbone.Collection
  model: Wiki.Models.Section

