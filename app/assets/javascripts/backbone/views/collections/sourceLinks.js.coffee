class Wiki.Views.SourceLinks extends Backbone.View

  initialize: ->
    @render()

  render: ->
   self = @
   contribPrefix = "contribution:"
   if Wiki.pageTitle.toLowerCase().substring(0, contribPrefix.length) == contribPrefix
    @model.fetch({
      url: self.model.urlBase + Wiki.pageTitle.substring(contribPrefix.length) + '.jsonp'
      dataType: 'jsonp'
      success: (data, res, o) ->
        self.addAll()
    })

  addOne: (link) ->
    sourceview = new Wiki.Views.SourceLink(model: link)
    sourceview.render()

  addAll: ->
    self = @
    $('#sourcelinks').find('.dropdown-menu').html('')
    $.each @model.models, (i, link) ->
      self.addOne(link)
