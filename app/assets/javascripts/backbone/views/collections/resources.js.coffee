class Wiki.Views.Resources extends Backbone.View

  initialize: ->
    @render()

  render: ->
    self = @
    @model.fetch({
      url: self.model.urlBase + Wiki.Utils.escapeURI(Wiki.pageTitle) + '.jsonp'
      dataType: 'jsonp'
      success: (data,res,o) ->
        self.addAll()
    })

  addOne: (resource) ->
    resourceview = new Wiki.Views.Resource(model: resource)
    resourceview.render()

  addAll: ->
    self = @
    resources = _.filter(@model.models, (r) -> not r.get('error'))
    if resources
      $.each resources, (i,resource) ->
        self.addOne(resource)

