class Wiki.Views.ExTriples extends Backbone.View
  resourceTemplate : JST['backbone/templates/resource']
  resourceBoxTemplate : JST['backbone/templates/resourcebox']

  prefixToName : {'www.haskell.org': 'HaskellWiki', 'en.wikipedia.org' : 'Wikipedia', 'en.wikibooks.org': 'Wikibooks', 'www.youtube.com' : "YouTube"}

  render: ->
    self = @
    fullName = @prefixToName[@model.get('node').split('/')[2]]
    place = $('#resources').find('.' + fullName)
    info = {'full' : @model.get('node'), 'chapter': _.last(@model.get('node').split('/')).replace('%28', '(').replace('%29', ')').replace('_', ' ').replace('_', ' ')}
    if place.length
      $(place).find('.resourcebar').append($(self.resourceBoxTemplate(cat:'primary', link:info)).tooltip("show"))
    else
      @setElement($(@resourceTemplate(fullName: fullName, name: fullName.replace(/\w/, ''))))
      $(@el).find('.resourcebar').append($(self.resourceBoxTemplate(cat:'primary', link:info)).tooltip("show"))
      $('#resources').append(@el)
      $(@el).find('.resourcename').mouseenter( ->
        $(self.el).find('.resourcebar').first().collapse('show')
      )
      $(@el).mouseleave(
        -> $(self.el).find('.resourcebar').first().collapse('hide')
      )
