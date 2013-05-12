class Wiki.Views.SourceLink extends Backbone.View
  resourceLinkTemplate : JST['backbone/templates/sourceDropdown']
  el: "#sourcelinks"

  render: ->
    $(@el).css('visibility', 'visible')
    $(@el).find('.dropdown-menu').append($(@resourceLinkTemplate(@model.toJSON()))).tab('show');
