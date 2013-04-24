class Wiki.Views.Search extends Backbone.View
  el: '#page'
  template : JST['backbone/templates/searchResult']

  initialize: ->
    @render()

  render: ->
   self = @
   $('#query-string').text('Search results for "' + Wiki.queryString + '"')
   _.each Wiki.searchResults, (link) ->
      $('#search-results ul').append(self.template(link: link.replace(/\s/g, '_'), name: link.replace(/_/g, ' ')))


