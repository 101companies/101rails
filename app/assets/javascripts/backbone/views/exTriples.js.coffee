class Wiki.Views.ExTriples extends Backbone.View
  resourceTemplate : JST['backbone/templates/resource']
  resourceBoxTemplate : JST['backbone/templates/resourcebox']

  prefixToName : {'www.haskell.org': 'HaskellWiki', 'en.wikipedia.org' : 'Wikipedia', 'en.wikibooks.org': 'Wikibooks', 'www.youtube.com' : "YouTube"}

  decode: (str, toLower) ->
    resBase = "http://101companies.org/resource/"
    str = decodeURIComponent(str.replace(resBase,"").replace("-3A",":").replace("Property:", "").replace(/_/g, " ").replace(/-/g, '%'))
    str = _.last(str.split("/"))
    if toLower
      firstLetter = str.substr(0, 1)
      firstLetter.toLowerCase() + str.substr(1)
    else
      str

  render: ->
    self = @
    key = @model.get('node').split('/')[2]
    if key of @prefixToName
      fullName = @prefixToName[key]
    else
      fullName = key
    place = $('#resources').find('.' + fullName)
    info = {'full' : @model.get('node'), 'chapter': _.last(@model.get('node').split('/')).replace('%28', '(').replace('%29', ')').replace('_', ' ').replace('_', ' ')}
    if place.length
      $(place).find('.resourcebar').append($(self.resourceBoxTemplate(cat:'primary', link:info, predicate: @decode(@model.get('predicate')))).tooltip("show"))
    else
      @setElement($(@resourceTemplate(fullName: fullName, name: fullName.replace(/\w/, ''))))
      $(@el).find('.resourcebar').append($(self.resourceBoxTemplate(cat:'primary', link:info, predicate: @decode(@model.get('predicate')))).tooltip("show"))
      $('#resources').append(@el)
      $(@el).find('.resourcename').mouseenter( ->
        $(self.el).find('.resourcebar').first().collapse('show')
      )
      $(@el).mouseleave(
        -> $(self.el).find('.resourcebar').first().collapse('hide')
      )
